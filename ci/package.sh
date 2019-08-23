#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

. $base_dir/ci/env.sh $base_dir

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets

mkdir -p $assets_dir

#expose an extension point for running before main 'package' processing
if [ -f $base_dir/ci/ext/pre_package.sh ]
then
    . $base_dir/ci/ext/pre_package.sh $base_dir
fi

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        index_file=$assets_dir/$repo_name-index.yaml
        index_file_local=$assets_dir/$repo_name-index-local.yaml

        echo "apiVersion: v2" > $index_file
        echo "stacks:" >> $index_file

        echo "apiVersion: v2" > $index_file_local
        echo "stacks:" >> $index_file_local

        # iterate over each stack
        for stack in $repo_dir/*/stack.yaml
        do
            stack_dir=$(dirname $stack)
            if [ -d $stack_dir ]
            then
                stack_id=$(basename $stack_dir)
                stack_version=$(awk '/^version *:/ { gsub("version:","",$NF); gsub("\"","",$NF); print $NF}' $stack)

                # check if the stack needs to be built
                build=false
                for repo_stack in $STACKS_LIST
                do
                    if [ $repo_stack = $repo_name/$stack_id ]
                    then
                        build=true
                    fi
                done

                if [ $build = true ]
                then
                    echo -e "\n- BUILDING stack: $repo_name/$stack_id"
                    stack_version_major=`echo $stack_version | cut -d. -f1`
                    stack_version_minor=`echo $stack_version | cut -d. -f2`
                    stack_version_patch=`echo $stack_version | cut -d. -f3`

                    if [ -d $stack_dir/image ]
                    then
                        docker build -t $DOCKERHUB_ORG/$stack_id \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor.$stack_version_patch \
                            -f $stack_dir/image/Dockerfile-stack $stack_dir/image
                    fi

                    echo "  - id: $stack_id" >> $index_file_local
                    sed 's/^/    /' $stack >> $index_file_local
                    [ -n "$(tail -c1 $index_file_local)" ] && echo >> $index_file_local
                    echo "    templates:" >> $index_file_local
                else
                    echo -e "\n- SKIPPING stack: $repo_name/$stack_id"
                fi

                echo "  - id: $stack_id" >> $index_file
                sed 's/^/    /' $stack >> $index_file
                [ -n "$(tail -c1 $index_file)" ] && echo >> $index_file
                echo "    templates:" >> $index_file

                for template_dir in $stack_dir/templates/*/
                do
                    if [ -d $template_dir ]
                    then
                        template_id=$(basename $template_dir)
                        template_archive=$repo_name.$stack_id.templates.$template_id.tar.gz
                        # Kabanero override (separate entry to stop merge conflicts)
                        template_archive=$repo_name.$stack_id.v$stack_version.templates.$template_id.tar.gz

                        if [ $build = true ]
                        then
                            if [ $stack_version_major -gt 0 ]
                            then
                                echo "stack: "$DOCKERHUB_ORG/$stack_id:$stack_version_major > $template_dir/.appsody-config.yaml
                            else
                                echo "stack: "$DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor > $template_dir/.appsody-config.yaml
                            fi
                            # build template archives
                            tar -cz -f $assets_dir/$template_archive -C $template_dir .
                            rm $template_dir/.appsody-config.yaml
                            echo -e "--- Created template archive: $template_archive"

                            echo "      - id: $template_id" >> $index_file_local
                            echo "        url: file://$assets_dir/$template_archive" >> $index_file_local
                        fi

                        echo "      - id: $template_id" >> $index_file
                        echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$template_archive" >> $index_file
                    fi
                done
            fi
        done
    else
        echo "SKIPPING: $repo_dir"
    fi
done

#expose an extension point for running after main 'package' processing
if [ -f $base_dir/ci/ext/post_package.sh ]
then
    . $base_dir/ci/ext/post_package.sh $base_dir
fi

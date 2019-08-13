#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

. $base_dir/ci/env.sh

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets

mkdir -p $assets_dir

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        index_file_v1=$assets_dir/$repo_name-index-v1.yaml
        index_file_v2=$assets_dir/$repo_name-index.yaml
        index_file_test=$assets_dir/$repo_name-index-test.yaml

        echo "apiVersion: v1" > $index_file_v1
        echo "projects:" >> $index_file_v1

        echo "apiVersion: v2" > $index_file_v2
        echo "stacks:" >> $index_file_v2

        echo "apiVersion: v2" > $index_file_test
        echo "stacks:" >> $index_file_test

        # iterate over each stack
        for stack in $repo_dir/*/stack.yaml
        do
            stack_dir=$(dirname $stack)
            if [ -d $stack_dir ]
            then
                i=0
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
                else
                    echo -e "\n- SKIPPING stack: $repo_name/$stack_id"
                fi

                echo "  $stack_id:" >> $index_file_v1
                echo "  - updated: $(date -u +'%Y-%m-%dT%H:%M:%S%z')"  >> $index_file_v1
                sed 's/^/    /' $stack >> $index_file_v1
                [ -n "$(tail -c1 $index_file_v1)" ] && echo >> $index_file_v1
                echo "    urls:" >> $index_file_v1

                echo "  - id: $stack_id" >> $index_file_v2
                sed 's/^/    /' $stack >> $index_file_v2
                [ -n "$(tail -c1 $index_file_v2)" ] && echo >> $index_file_v2
                echo "    templates:" >> $index_file_v2

                echo "  - id: $stack_id" >> $index_file_test
                sed 's/^/    /' $stack >> $index_file_test
                [ -n "$(tail -c1 $index_file_test)" ] && echo >> $index_file_test
                echo "    templates:" >> $index_file_test

                for template_dir in $stack_dir/templates/*/
                do
                    if [ -d $template_dir ]
                    then
                        template_id=$(basename $template_dir)
                        template_archive=$repo_name.$stack_id.templates.$template_id.tar.gz

                        if [ $build = true ]
                        then
                            # build template archives
                            tar -cz -f $assets_dir/$template_archive -C $template_dir .
                            echo -e "--- Created template archive: $template_archive"
                        fi

                        echo "      - id: $template_id" >> $index_file_v2
                        echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$template_archive" >> $index_file_v2

                        echo "      - id: $template_id" >> $index_file_test
                        echo "        url: file://$assets_dir/$template_archive" >> $index_file_test

                        if [ $i -eq 0 ]
                        then
                            echo "    - $RELEASE_URL/$stack_id-v$stack_version/$template_archive" >> $index_file_v1
                            ((i+=1))
                        fi
                    fi
                done
            fi
        done
    else
        echo "SKIPPING: $repo_dir"
    fi
done

#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# packaging/publishing settings
. $base_dir/ci/env.sh $base_dir

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets

mkdir -p $assets_dir

#expose an extension point for running before main 'package' processing
if [ -f $base_dir/ci/ext/pre_package.sh ]
then
    . $base_dir/ci/ext/pre_package.sh $base_dir
fi

package_template() {
    local template_dir=$1
    local build_me=$2
    local build_mode=$3

    if [ -d $template_dir ]
    then
        echo "    templates:" >> $index_file
        echo "    templates:" >> $index_file_local

        for dir in $template_dir/*/
        do
            if [ -d "$dir" ]
            then
                template_id=$(basename $dir)
                template_archive=$repo_name.$stack_id.templates.$template_id.tar.gz

                if [ $build_me ]
                then
                  case "$build_mode" in
                    tar)
                        # build template archives
                        tar -cz -f $assets_dir/$template_archive -C $template_dir .
                        echo -e "--- Created template archive: $template_archive"
                    ;;
                    extract)
                        docker run --rm -iv${assets_dir}:/host-volume --entrypoint "" \
                          $DOCKERHUB_ORG/$stack_id sh -c "cp /templates/${template_id}.tar.gz /host-volume/${template_archive}; \
                                chown $(id -u):$(id -g) /host-volume/${template_archive}"
                        echo -e "--- Extracted template archive: $template_archive"
                    ;;
                  esac
                fi

                echo "      - id: $template_id" >> $index_file
                echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$template_archive" >> $index_file

                echo "      - id: $template_id" >> $index_file_local
                echo "        url: file://$assets_dir/$template_archive" >> $index_file_local
            fi
        done
    fi
}

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
                        docker build \
                            --build-arg REPO_SLUG=$REPO_SLUG \
                            --build-arg DOCKERHUB_ORG=$DOCKERHUB_ORG \
                            --build-arg STACK_ID=$stack_id \
                            --build-arg MAJOR_VERSION=$stack_version_major \
                            --build-arg MINOR_VERSION=$stack_version_minor \
                            --build-arg PATCH_VERSION=$stack_version_patch \
                            -t $DOCKERHUB_ORG/$stack_id \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor.$stack_version_patch \
                            -f $stack_dir/image/Dockerfile-stack $stack_dir/image
                    fi
                else
                    echo -e "\n- SKIPPING stack: $repo_name/$stack_id"
                fi

                echo "  - id: $stack_id" >> $index_file
                sed 's/^/    /' $stack >> $index_file
                [ -n "$(tail -c1 $index_file)" ] && echo >> $index_file
                echo "    default-image: $DOCKERHUB_ORG/$stack_id:$stack_version" >> $index_file

                echo "  - id: $stack_id" >> $index_file_local
                sed 's/^/    /' $stack >> $index_file_local
                [ -n "$(tail -c1 $index_file_local)" ] && echo >> $index_file_local
                echo "    default-image: $DOCKERHUB_ORG/$stack_id:$stack_version" >> $index_file_local

                # Create or extract template archives
                if [ -d $stack_dir/templates ]
                then
                    package_template "$stack_dir/templates" $build tar
                elif [ -d $stack_dir/image/templates ]
                then
                    package_template "$stack_dir/image/templates" $build extract
                fi
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


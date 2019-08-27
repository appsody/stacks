#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

mkdir -p $build_dir/index-src

# remember images to push
> $build_dir/image_list

# expose an extension point for running before main 'package' processing
if [ -f $script_dir/ext/pre_package.sh ]
then
    . $script_dir/ext/pre_package.sh $base_dir
fi

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        # versioned stack directory for per-stack release
        index_file=$assets_dir/$repo_name-index.yaml

        # flat index used by static appsody-index and local test repo
        index_src=$build_dir/index-src/$repo_name-index.yaml
        index_file_local=$assets_dir/$repo_name-index-local.yaml

        echo "apiVersion: v2" > $index_src
        echo "stacks:" >> $index_src

        echo "apiVersion: v2" > $index_file_local
        echo "stacks:" >> $index_file_local

        echo "apiVersion: v2" > $index_file
        echo "stacks:" >> $index_file

        # iterate over each stack
        for stack in $repo_dir/*/stack.yaml
        do
            stack_dir=$(dirname $stack)
            if [ -d $stack_dir ]
            then
                stack_id=$(basename $stack_dir)
                stack_version=$(awk '/^version *:/ { gsub("version:","",$NF); gsub("\"","",$NF); print $NF}' $stack)
                stack_version_major=`echo $stack_version | cut -d. -f1`
                stack_version_minor=`echo $stack_version | cut -d. -f2`
                stack_version_patch=`echo $stack_version | cut -d. -f3`

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

                    if [ -d $stack_dir/image ]
                    then
                        docker build \
                            --build-arg GIT_ORG_REPO=$GIT_ORG_REPO \
                            --build-arg DOCKERHUB_ORG=$DOCKERHUB_ORG \
                            --build-arg STACK_ID=$stack_id \
                            --build-arg MAJOR_VERSION=$stack_version_major \
                            --build-arg MINOR_VERSION=$stack_version_minor \
                            --build-arg PATCH_VERSION=$stack_version_patch \
                            --label "org.opencontainers.image.created=$(date +%Y-%m-%dT%H:%M:%S%z)" \
                            --label "org.opencontainers.image.version=${stack_version}" \
                            --label "org.opencontainers.image.revision=$(git log -1 --pretty=%H)" \
                            -t $DOCKERHUB_ORG/$stack_id \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor \
                            -t $DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor.$stack_version_patch \
                            -f $stack_dir/image/Dockerfile-stack $stack_dir/image

                        echo "$DOCKERHUB_ORG/$stack_id" >> $build_dir/image_list
                        echo "$DOCKERHUB_ORG/$stack_id:$stack_version_major" >> $build_dir/image_list
                        echo "$DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor" >> $build_dir/image_list
                        echo "$DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor.$stack_version_patch" >> $build_dir/image_list
                    fi
                else
                    echo -e "\n- SKIPPING stack image: $repo_name/$stack_id"
                fi

                echo "  - id: $stack_id" >> $index_src
                sed 's/^/    /' $stack >> $index_src
                [ -n "$(tail -c1 $index_src)" ] && echo >> $index_src
                echo "    templates:" >> $index_src

                if [ $build = true ]
                then
                    echo "  - id: $stack_id" >> $index_file_local
                    sed 's/^/    /' $stack >> $index_file_local
                    [ -n "$(tail -c1 $index_file_local)" ] && echo >> $index_file_local
                    echo "    templates:" >> $index_file_local
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
                        old_archive=$repo_name.$stack_id.templates.$template_id.tar.gz
                        versioned_archive=$repo_name.$stack_id.v$stack_version.templates.$template_id.tar.gz

                        # build archive if it doesn't exist
                        if [ "$PACKAGE_WHEN_MISSING" = "true" ] && [ ! -f $assets_dir/$old_archive ] && [ ! -f $assets_dir/$versioned_archive ]
                        then
                        #     build=true
                        # fi

                        # build template archive; include version in the file name
                        # if [ $build = true ]
                        # then
                            if [ $stack_version_major -gt 0 ]
                            then
                                echo "stack: "$DOCKERHUB_ORG/$stack_id:$stack_version_major > $template_dir/.appsody-config.yaml
                            else
                                echo "stack: "$DOCKERHUB_ORG/$stack_id:$stack_version_major.$stack_version_minor > $template_dir/.appsody-config.yaml
                            fi

                            tar -cz -f $assets_dir/$versioned_archive -C $template_dir .
                            rm $template_dir/.appsody-config.yaml
                            echo -e "--- Created template archive: $versioned_archive"
                        fi

                        # Update index yaml based on archive file name (prefer versioned archives)
                        if [ -f $assets_dir/$versioned_archive ]
                        then
                            echo "      - id: $template_id" >> $index_src
                            echo "        url: {{EXTERNAL_URL}}/$versioned_archive" >> $index_src

                            if [ $build = true ]
                            then
                                echo "      - id: $template_id" >> $index_file_local
                                echo "        url: file://$assets_dir/$versioned_archive" >> $index_file_local
                            fi

                            echo "      - id: $template_id" >> $index_file
                            echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$versioned_archive" >> $index_file
                        elif [ -f $assets_dir/$old_archive ]
                        then
                            # If an archive exists with no version in the name,
                            # check for a prefetch script that can verify it
                            # matches this stack. This helps ensure that the new
                            # stack image
                            if [ -f $build_dir/prefetch-${stack_id}-${template_id} ]
                            then
                                result=$($build_dir/prefetch-${stack_id}-${template_id} ${stack_version})
                                if [ "$result" == "ok" ]
                                then
                                    echo "template ok"
                                else
                                    if [ "$result" == "nomatch" ]
                                    then
                                        >&2 echo "WARNING: checksum for $old_archive doesn't match."
                                        >&2 echo "         The archive contents don't match what was fetched."
                                        >&2 echo "         Pre-fetched checksum is in ${build_dir}/prefetch-${stack_id}-${template_id}"
                                    else
                                        >&2 echo "WARNING: Version mismatch using $template_id for ${stack_id}-v${stack_version}."
                                        >&2 echo "         Pre-fetched archive built for ${stack_id}-v${result}."
                                    fi
                                fi
                            fi

                            echo "      - id: $template_id" >> $index_src
                            echo "        url: {{EXTERNAL_URL}}/$old_archive" >> $index_src

                            if [ $build = true ]
                            then
                                echo "      - id: $template_id" >> $index_file_local
                                echo "        url: file://$assets_dir/$old_archive" >> $index_file_local
                            fi

                            echo "      - id: $template_id" >> $index_file
                            echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$old_archive" >> $index_file
                        else
                            >&2 echo "ERROR: could not find an archive for $stack_id/$template_id:"
                            >&2 echo "       $versioned_archive not found."
                            >&2 echo "       $old_archive not found."
                        fi
                    fi
                done
            fi
        done
    else
        echo "SKIPPING: $repo_dir"
    fi

done

#expose an extension point for running after main 'package' processing
if [ -f $script_dir/ext/post_package.sh ]
then
    . $script_dir/ext/post_package.sh $base_dir
fi

# create appsody-index from contents of assets directory after post-processing
echo -e "\nBUILDING: $DOCKERHUB_ORG/$INDEX_IMAGE:${INDEX_VERSION}"

nginx_arg=
if [ -n "$NGINX_IMAGE" ]
then
    nginx_arg="--build-arg NGINX_IMAGE=$NGINX_IMAGE"
fi

docker build $nginx_arg \
 -t $DOCKERHUB_ORG/$INDEX_IMAGE \
 -t $DOCKERHUB_ORG/$INDEX_IMAGE:${INDEX_VERSION} \
 -f $script_dir/nginx/Dockerfile $script_dir

echo "$DOCKERHUB_ORG/$INDEX_IMAGE" >> $build_dir/image_list
echo "$DOCKERHUB_ORG/$INDEX_IMAGE:${INDEX_VERSION}" >> $build_dir/image_list

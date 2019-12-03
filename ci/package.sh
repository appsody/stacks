#!/bin/bash

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

mkdir -p $build_dir/index-src

# remember images to push
> $build_dir/image_list

# expose an extension point for running before main 'package' processing
exec_hooks $script_dir/ext/pre_package.d

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
                rebuild_local=false
                for repo_stack in $STACKS_LIST
                do
                    if [ $repo_stack = $repo_name/$stack_id ]
                    then
                        rebuild_local=true
                    fi
                done

                if [ $rebuild_local = true ]
                then
                    echo -e "\n- BUILDING stack: $repo_name/$stack_id"

                    if [ -d $stack_dir/image ]
                    then
                        if ${CI_WAIT_FOR} image_build \
                            --build-arg GIT_ORG_REPO=$GIT_ORG_REPO \
                            --build-arg IMAGE_REGISTRY_ORG=$IMAGE_REGISTRY_ORG \
                            --build-arg STACK_ID=$stack_id \
                            --build-arg MAJOR_VERSION=$stack_version_major \
                            --build-arg MINOR_VERSION=$stack_version_minor \
                            --build-arg PATCH_VERSION=$stack_version_patch \
                            --label "org.opencontainers.image.created=$(date +%Y-%m-%dT%H:%M:%S%z)" \
                            --label "org.opencontainers.image.version=${stack_version}" \
                            --label "org.opencontainers.image.revision=$(git log -1 --pretty=%H)" \
                            --label "appsody.stack=$IMAGE_REGISTRY_ORG/$stack_id:$stack_version" \
                            -t $IMAGE_REGISTRY_ORG/$stack_id \
                            -t $IMAGE_REGISTRY_ORG/$stack_id:$stack_version \
                            -t $IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major \
                            -t $IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major.$stack_version_minor \
                            -f $stack_dir/image/Dockerfile-stack $stack_dir/image \
                            > ${build_dir}/image.$stack_id.$stack_version.log 2>&1
                        then
                            echo "File containing output from image build: ${build_dir}/image.$stack_id.$stack_version.log"
                            trace  "Output from image build" "${build_dir}/image.$stack_id.$stack_version.log"

                            echo "created $IMAGE_REGISTRY_ORG/$stack_id:$stack_version"
                            echo "$IMAGE_REGISTRY_ORG/$stack_id:$stack_version" >> $build_dir/image_list
                            if [ $LATEST_RELEASE == true ]; then
                                echo "$IMAGE_REGISTRY_ORG/$stack_id" >> $build_dir/image_list
                                echo "$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major" >> $build_dir/image_list
                                echo "$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major.$stack_version_minor" >> $build_dir/image_list
                            fi
                        else
                            echo "Error building $IMAGE_REGISTRY_ORG/$stack_id:$stack_version"
                            cat ${build_dir}/image.$stack_id.$stack_version.log
                            exit 1
                        fi
                    fi
                else
                    echo -e "\n- SKIPPING stack image: $repo_name/$stack_id"
                fi

                echo "  - id: $stack_id" >> $index_src
                sed 's/^/    /' $stack >> $index_src
                [ -n "$(tail -c1 $index_src)" ] && echo >> $index_src
                echo "    templates:" >> $index_src

                if [ $rebuild_local = true ]
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

                        build=$rebuild_local
                        if [ "$PACKAGE_WHEN_MISSING" = "true" ] &&
                            [ ! -f $assets_dir/$versioned_archive ] &&
                            [ ! -f $prefetch_dir/$old_archive ] &&
                            [ ! -f $prefetch_dir/$versioned_archive ]
                        then
                            # force build of template archive if it doesn't exist
                            build=true
                        fi

                        if [ $build = true ]
                        then
                            # build template archive; include version in the file name
                            if [ $stack_version_major -gt 0 ]
                            then
                                echo "stack: "$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major > $template_dir/.appsody-config.yaml
                            else
                                echo "stack: "$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major.$stack_version_minor > $template_dir/.appsody-config.yaml
                            fi

                            tar -cz -f $assets_dir/$versioned_archive -C $template_dir .
                            rm $template_dir/.appsody-config.yaml
                            echo -e "--- Created template archive: $versioned_archive"

                            # clean up prefetched resources if they exist
                            rm -f $prefetch_dir/${old_archive%.tar.gz}*
                        fi

                        # Update index yaml based on archive file name (prefer versioned archives)
                        if [ -f $assets_dir/$versioned_archive ]
                        then
                            echo "      - id: $template_id" >> $index_src
                            echo "        url: {{EXTERNAL_URL}}/$versioned_archive" >> $index_src

                            if [ $rebuild_local = true ]
                            then
                                echo "      - id: $template_id" >> $index_file_local
                                echo "        url: file://$assets_dir/$versioned_archive" >> $index_file_local
                            fi

                            echo "      - id: $template_id" >> $index_file
                            echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$versioned_archive" >> $index_file
                        elif [ -f $prefetch_dir/$versioned_archive ]
                        then
                            echo "$template_id template ok"

                            # Add references to existing template archive.
                            echo "      - id: $template_id" >> $index_src
                            echo "        url: {{EXTERNAL_URL}}/$versioned_archive" >> $index_src

                            echo "      - id: $template_id" >> $index_file
                            echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$versioned_archive" >> $index_file
                        elif [ -f $prefetch_dir/$old_archive ]
                        then
                            verify="$build_dir/prefetch-${repo_name}-${stack_id}-${template_id}"

                            # If an archive exists with no version in the name,
                            # check for a prefetch script that can verify it
                            # matches this stack. This helps ensure that the new
                            # stack image
                            if [ -f ${verify} ]
                            then
                                result=$(${verify} ${stack_version})
                                if [ "$result" == "ok" ]
                                then
                                    echo "$template_id template ok"
                                else
                                    if [ "$result" == "nomatch" ]
                                    then
                                        stderr "WARNING: checksum for $old_archive doesn't match." \
                                               "         The archive contents don't match what was fetched." \
                                               "         Pre-fetched checksum is in ${verify}"
                                    else
                                        stderr "WARNING: Version mismatch using $template_id for ${stack_id}-v${stack_version}." \
                                               "         Pre-fetched archive built for ${stack_id}-v${result}."
                                    fi
                                fi
                            fi

                            # Add references to existing/old template archives.

                            echo "      - id: $template_id" >> $index_src
                            echo "        url: {{EXTERNAL_URL}}/$old_archive" >> $index_src

                            echo "      - id: $template_id" >> $index_file
                            echo "        url: $RELEASE_URL/$stack_id-v$stack_version/$old_archive" >> $index_file

                        else
                            if [ $rebuild_local = true ]; then
                                stderr "ERROR: Could not find an archive for $stack_id/$template_id:" \
                                       "       $versioned_archive not found." \
                                       "       $old_archive not found."
                            fi       
                        fi
                    fi
                done
            fi
        done
    else
        echo "SKIPPING: $repo_dir"
    fi

done

# expose an extension point for running after main 'package' processing
exec_hooks $script_dir/ext/post_package.d

if [ "$CODEWIND_INDEX" == "true" ]; then
    python3 $script_dir/create_codewind_index.py $DISPLAY_NAME_PREFIX

    # iterate over each repo
    for codewind_file in $assets_dir/*.json
    do
        # flat json used by static appsody-index for codewind
        index_src=$build_dir/index-src/$(basename "$codewind_file")

        sed -e "s|${RELEASE_URL}/.*/|{{EXTERNAL_URL}}/|" $codewind_file > $index_src
    done
fi

# create appsody-index from contents of assets directory after post-processing
echo -e "\nBUILDING: $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"

nginx_arg=
if [ -n "$NGINX_IMAGE" ]
then
    nginx_arg="--build-arg NGINX_IMAGE=$NGINX_IMAGE"
fi

if ${CI_WAIT_FOR} image_build $nginx_arg \
    -t $IMAGE_REGISTRY_ORG/$INDEX_IMAGE \
    -t $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION} \
    -f $script_dir/nginx/Dockerfile $script_dir \
    > ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log
then
    echo "File containing output from $INDEX_IMAGE build: ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
    trace  "Output from $INDEX_IMAGE build" "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"

    echo "created $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    echo "$IMAGE_REGISTRY_ORG/$INDEX_IMAGE" >> $build_dir/image_list
    echo "$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" >> $build_dir/image_list
else
    echo "failed building $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    cat "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
    exit 1
fi

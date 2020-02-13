#!/bin/bash -x

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
    useCachedIndex=""
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        # versioned stack directory for per-stack release
        index_file=$assets_dir/$repo_name-index.yaml

        # flat index used by static appsody-index and local test repo
        index_src=$build_dir/index-src/$repo_name-index.yaml

        # iterate over each stack
        for stack in $(ls $repo_dir/*/stack.yaml 2>/dev/null | sort)
        do
            echo $stack
            stack_dir=$(dirname $stack)

            if [ -d $stack_dir ]
            then
                pushd $stack_dir

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
                    echo -e "\n- LINTING stack: $repo_name/$stack_id"
                    if appsody stack lint 
                    then
                        echo "appsody stack lint: ok"
                    else
                        echo "Error linting $repo_name/$stack_id"
                        exit 1
                    fi

                    rm -f ${build_dir}/*.$stack_id.$stack_version.log

                    echo -e "\n- PACKAGING stack: $repo_name/$stack_id, log: ${build_dir}/package.$stack_id.$stack_version.log"
                    echo "PACKAGING stack: $repo_name/$stack_id" > ${build_dir}/package.$stack_id.$stack_version.log
                    if logged ${build_dir}/package.$stack_id.$stack_version.log \
                        appsody stack package \
                        --image-registry $IMAGE_REGISTRY \
                        --image-namespace $IMAGE_REGISTRY_ORG
                    then
                        echo "appsody stack package: ok, $IMAGE_REGISTRY_ORG/$stack_id:$stack_version"
                        trace "${build_dir}/package.$stack_id.$stack_version.log"

                        if [ "$SKIP_TESTS" != "true" ]
                        then
                            echo -e "\n- VALIDATING stack: $repo_name/$stack_id, log: ${build_dir}/validate.$stack_id.$stack_version.log"
                            echo "VALIDATING stack: $repo_name/$stack_id" > ${build_dir}/validate.$stack_id.$stack_version.log
                            if logged ${build_dir}/validate.$stack_id.$stack_version.log \
                                appsody stack validate \
                                --no-lint --no-package \
                                --image-registry $IMAGE_REGISTRY \
                                --image-namespace $IMAGE_REGISTRY_ORG
                            then
                                echo "appsody stack validate: ok"
                                trace "${build_dir}/validate.$stack_id.$stack_version.log"
                            else
                                stderr "${build_dir}/validate.$stack_id.$stack_version.log" 
                                stderr "appsody stack validate: error"
                                exit 1
                            fi
                        fi
                    else
                        stderr "${build_dir}/package.$stack_id.$stack_version.log"
                        stderr "appsody stack package: error" 
                        exit 1
                    fi

                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id" >> $build_dir/image_list
                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id:$stack_version" >> $build_dir/image_list
                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major" >> $build_dir/image_list
                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major.$stack_version_minor" >> $build_dir/image_list

                    echo -e "\n- ADD $repo_name with release URL prefix $RELEASE_URL/$stack_id-v$stack_version/$repo_name."
                    if appsody stack add-to-repo $repo_name \
                        --release-url $RELEASE_URL/$stack_id-v$stack_version/$repo_name. \
                        $useCachedIndex
                    then
                        useCachedIndex="--use-local-cache"
                    else
                        echo "Error running 'appsody stack add-to-repo' command"
                        exit 1
                    fi

                    for template_dir in $stack_dir/templates/*/
                    do
                        if [ -d $template_dir ]
                        then
                            template_id=$(basename $template_dir)
                            versioned_archive=$repo_name.$stack_id.v$stack_version.templates.$template_id.tar.gz
                            packaged_archive=$stack_id.v$stack_version.templates.$template_id.tar.gz
                            if [ -f $HOME/.appsody/stacks/dev.local/$packaged_archive ]; then
                                echo "--- Copying $HOME/.appsody/stacks/dev.local/$packaged_archive to $assets_dir/$versioned_archive"
                                cp $HOME/.appsody/stacks/dev.local/$packaged_archive $assets_dir/$versioned_archive
                            fi
                        fi
                    done
                    source_archive=$repo_name.$stack_id.v$stack_version.source.tar.gz
                    packaged_source_archive=$stack_id.v$stack_version.source.tar.gz
                    if [ -f $HOME/.appsody/stacks/dev.local/$packaged_source_archive ]; then
                        echo "--- Copying $HOME/.appsody/stacks/dev.local/$packaged_source_archive to $assets_dir/$source_archive"
                        cp $HOME/.appsody/stacks/dev.local/$packaged_source_archive $assets_dir/$source_archive
                    fi
                else
                    echo -e "\n- SKIPPING stack image: $repo_name/$stack_id"
                fi

                popd
            fi
        done

        for repo_stack in $STACKS_LIST
        do
            stack_dir=$(dirname $repo_stack)
            stack_id=$(basename $repo_stack)
            if [ "${stack_dir}" == "${repo_name}" ]; then
                if [ ! -d $repo_stack ]
                then
                    echo -e "\n- REMOVING stack image: $stack_dir/$stack_id"
                    echo "File containing output from remove-from-repo: ${build_dir}/remove-from-repo.$stack_id.log"
                    if ${CI_WAIT_FOR} appsody stack remove-from-repo $stack_dir $stack_id -v $useCachedIndex \
                        > ${build_dir}/remove-from-repo.$stack_id.log 2>&1
                    then
                        useCachedIndex="--use-local-cache"
                        trace  "Output from remove-from-repo command" "${build_dir}/remove-from-repo.$stack_id.log"
                    else
                        echo "Error running `appsody stack remove-from-repo` command"
                        cat ${build_dir}/remove-from-repo.$stack_id.log
                        exit 1
                    fi
                fi
            fi
        done

        if [ "$useCachedIndex" != "" ]; then
            if [ -f $HOME/.appsody/stacks/dev.local/$repo_name-index.yaml ]; then
                cp $HOME/.appsody/stacks/dev.local/$repo_name-index.yaml $index_file
            fi
        else
            url="$RELEASE_URL/../latest/download/$repo_name-index.yaml"
            curl -s -L ${url} -o $index_file
        fi
        
        sed -e "s|${RELEASE_URL}/.*/|{{EXTERNAL_URL}}/|" $index_file > $index_src
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
echo -e "\n- BUILDING: $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}, log: ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"

nginx_arg=
if [ -n "$NGINX_IMAGE" ]
then
    nginx_arg="--build-arg NGINX_IMAGE=$NGINX_IMAGE"
fi

echo "BUILDING: $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" > ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log
if image_build ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log \
    $nginx_arg \
    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE \
    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION} \
    -f $script_dir/nginx/Dockerfile $script_dir
then
    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE" >> $build_dir/image_list
    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" >> $build_dir/image_list
    echo "created $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    trace "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
else
    stderr "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
    stderr "failed building $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    exit 1
fi

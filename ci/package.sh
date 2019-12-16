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
    useCachedIndex=""
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        # versioned stack directory for per-stack release
        index_file=$assets_dir/$repo_name-index.yaml

        # flat index used by static appsody-index and local test repo
        index_src=$build_dir/index-src/$repo_name-index.yaml

        # iterate over each stack
        for stack in $repo_dir/*/stack.yaml
        do
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
                    if [ "$SKIP_TESTS" = "true" ]; then
                        appsody_cmd="appsody stack package"
                        echo -e "\n- PACKAGING stack: $repo_name/$stack_id"
                    else
                        appsody_cmd="appsody stack validate"
                        echo -e "\n- VALIDATING stack: $repo_name/$stack_id"
                    fi
                    
                    logFileName=${build_dir}/image.$stack_id.$stack_version.log
                    rm -f $logFileName &> /dev/null
                    
                    retcode=0
                    
                    if [ "$CI_WAIT_FOR" != "" ]; then
                        $appsody_cmd -v --image-registry $IMAGE_REGISTRY --image-namespace $IMAGE_REGISTRY_ORG  2>&1 || retcode=$?
                    else
                        echo "File containing output from image build: $logFileName"
                        $appsody_cmd -v --image-registry $IMAGE_REGISTRY --image-namespace $IMAGE_REGISTRY_ORG  > $logFileName 2>&1 || retcode=$?
                    fi
                   
                    if [ $retcode != 0 ]; then
                        echo "Error building $IMAGE_REGISTRY_ORG/$stack_id:$stack_version"
                        if [ "$TRAVIS" != "true" ] && [ -f $logFileName ]; then
                           cat $logFileName
                        fi
                        exit 1
                    else
                        echo "Successfully built $IMAGE_REGISTRY_ORG/$stack_id:$stack_version"
                        if [ "$TRAVIS" != "true" ] && [ -f $logFileName ]; then
                            trace  "Output from image build" "$logFileName"
                        fi
                        echo "created $IMAGE_REGISTRY_ORG/$stack_id:$stack_version"
                    fi

                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id" >> $build_dir/image_list
                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id:$stack_version" >> $build_dir/image_list
                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major" >> $build_dir/image_list
                    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$stack_id:$stack_version_major.$stack_version_minor" >> $build_dir/image_list

                    echo "File containing output from add-to-repo: ${build_dir}/add-to-repo.$stack_id.$stack_version.log"
                    if ${CI_WAIT_FOR} appsody stack add-to-repo $repo_name -v --release-url $RELEASE_URL/$stack_id-v$stack_version/$repo_name. $useCachedIndex \
                        > ${build_dir}/add-to-repo.$stack_id.$stack_version.log 2>&1
                    then
                        useCachedIndex="--use-local-cache"
                        trace  "Output from add-to-repo command" "${build_dir}/add-to-repo.$stack_id.$stack_version.log"
                    else
                        echo "Error running `appsody stack add-to-repo` command"
                        cat ${build_dir}/add-to-repo.$stack_id.$stack_version.log
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
                else
                    echo -e "\n- SKIPPING stack image: $repo_name/$stack_id"
                fi

                popd
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
echo -e "\nBUILDING: $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"

nginx_arg=
if [ -n "$NGINX_IMAGE" ]
then
    nginx_arg="--build-arg NGINX_IMAGE=$NGINX_IMAGE"
fi

echo "File containing output from $INDEX_IMAGE build: ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
if ${CI_WAIT_FOR} image_build $nginx_arg \
    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE \
    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION} \
    -f $script_dir/nginx/Dockerfile $script_dir \
    > ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log
then
    trace  "Output from $INDEX_IMAGE build" "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"

    echo "created $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE" >> $build_dir/image_list
    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" >> $build_dir/image_list
else
    echo "failed building $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    cat "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
    exit 1
fi

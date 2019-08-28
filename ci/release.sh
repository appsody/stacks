#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# directory to store assets for test or release
release_dir=$script_dir/release
mkdir -p $release_dir

# expose an extension point for running before main 'release' processing
exec_hooks $script_dir/ext/pre_release.d

# iterate over each asset
for asset in $assets_dir/*
do
    if [[ $asset != *-local.yaml ]]
    then
        echo "Releasing: $asset"
        mv $asset $release_dir
    fi
done

# dockerhub/docker registry login in
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin $DOCKER_REGISTRY

if [ -f $build_dir/image_list ]
then
    while read line
    do
        if [ "$line" != "" ]
        then
            echo "Pushing image $line"
            docker push $line
        fi
    done < $build_dir/image_list
else
    # iterate over each stack
    for repo_stack in $STACKS_LIST
    do
        stack_id=`echo ${repo_stack/*\//}`
        echo "Releasing stack images for: $stack_id"
        docker push $DOCKERHUB_ORG/$stack_id
    done

    echo "Releasing stack index"
    docker push $DOCKERHUB_ORG/appsody_index
fi

# expose an extension point for running after main 'release' processing
exec_hooks $script_dir/ext/post_release.d

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
release_dir=$base_dir/ci/release

mkdir -p $release_dir

# expose an extension point for running before main 'release' processing
if [ -f $base_dir/ci/ext/pre_release.sh ]
then
    . $base_dir/ci/ext/pre_release.sh $base_dir
fi

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

# iterate over each stack
for repo_stack in $STACKS_LIST
do
    stack_id=`echo ${repo_stack/*\//}`
    echo "Releasing stack images for: $stack_id"
    docker push $DOCKERHUB_ORG/$stack_id
done

# expose an extension point for running after main 'release' processing
if [ -f $base_dir/ci/ext/post_release.sh ]
then
    . $base_dir/ci/ext/post_release.sh $base_dir
fi

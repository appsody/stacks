#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets
release_dir=$base_dir/ci/release

mkdir -p $release_dir

# iterate over each asset
for asset in $assets_dir/*
do
    if [[ $asset != *-test.yaml ]] && [[ $asset != *-v2.yaml ]]
    then
        echo "RELEASING: $asset"
        mv $asset $release_dir
    fi
done

# iterate over each stack
for repo_stack in $STACKS_LIST
do
    stack_id=`echo ${repo_stack/*\//}`
    echo "Releasing stack images for: $stack_id"
    echo "docker push $DOCKERHUB_ORG/$stack_id"
done
#!/bin/bash

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

image_registry_login

if [ -f $build_dir/image_list ]
then
    while read line
    do
        if [ "$line" != "" ]
        then
            image_push $line
        fi
    done < $build_dir/image_list
fi

# expose an extension point for running after main 'release' processing
exec_hooks $script_dir/ext/post_release.d

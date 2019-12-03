#!/bin/bash
set -e

if [ -z $BUILD_ALL ]
then
    export RELEASE_NAME="$stack_id-v$stack_version"
else
    if [ -z $TRAVIS_TAG ]; then
        if [ -f $base_dir/VERSION ]; then
            export RELEASE_NAME="$(cat $base_dir/VERSION)"
        else
            export RELEASE_NAME="$BUILD_ALL"
        fi
    else
        export RELEASE_NAME=$TRAVIS_TAG
    fi
fi

if [ -z $ASSET_LIST ]; then
    asset_list="pipelines dashboards deploys"
else 
    asset_list=$ASSET_LIST
fi

export COPYFILE_DISABLE=1

# Unset the INDEX_LIST variable that wopuld have been set by the Apposdy build
unset INDEX_LIST


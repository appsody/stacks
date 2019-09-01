#!/bin/bash
set -e

# Setup the environment variable needed to build Kabanero Collections
if [ -z $BUILD_ALL ]; then
    export BUILD_ALL=true
fi

if [ -z $REPO_LIST ]; then
    export REPO_LIST=incubator
fi

if [ -z $EXCLUDED_STACKS ]; then
    export EXCLUDED_STACKS=incubator/swift
fi

if [ -z $CODEWIND_INDEX ]; then
    export CODEWIND_INDEX=true
fi

if [ -z $INDEX_IMAGE ]; then
    export INDEX_IMAGE=kabanero-index
fi

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

# Unset the INDEX_LIST variable that wopuld have been set by the Apposdy build
unset INDEX_LIST


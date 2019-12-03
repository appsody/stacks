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
    export EXCLUDED_STACKS=""
fi
if [ -z $CODEWIND_INDEX ]; then
    export CODEWIND_INDEX=true
fi
if [ -z $INDEX_IMAGE ]; then
    export INDEX_IMAGE=kabanero-index
fi 
if [ -z "$DISPLAY_NAME_PREFIX" ]
then
    export DISPLAY_NAME_PREFIX="Kabanero"
fi
if [ -z "$IMAGE_REGISTRY_ORG" ]
then
    export IMAGE_REGISTRY_ORG="kabanero"
fi
if [ -z "$LATEST_RELEASE" ]; then
    export LATEST_RELEASE=false
fi


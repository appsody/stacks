#!/bin/bash
set -e

# Setup the environment variable needed to build Kabanero Collections
if [ -z "${BUILD_ALL}" ]; then
    export BUILD_ALL=true
fi
if [ -z "${REPO_LIST}" ]; then
    export REPO_LIST=incubator
fi
if [ -z "${EXCLUDED_STACKS}" ]; then
    export EXCLUDED_STACKS=""
fi
if [ -z "${CODEWIND_INDEX}" ]; then
    export CODEWIND_INDEX=true
fi
if [ -z "${INDEX_IMAGE}" ]; then
    export INDEX_IMAGE=kabanero-index
fi
if [ -z "${DISPLAY_NAME_PREFIX}" ]
then
    export DISPLAY_NAME_PREFIX="Kabanero"
fi
if [ -z "${IMAGE_REGISTRY_ORG}" ]
then
    export IMAGE_REGISTRY_ORG="kabanero"
fi
if [ -z "${LATEST_RELEASE}" ]; then
    export LATEST_RELEASE=true
fi
if [ "$TRAVIS" == "true" ]
then
    if [ $TRAVIS_TAG ] && [[ $TRAVIS_TAG =~ ^.*-(alpha|beta|rc)\.[0-9]* ]]
    then
        if [ -z "${BETA_REGISTRY_USERNAME}" ] || [ -z "${BETA_REGISTRY_PASSWORD}" ] || [ -z "${BETA_REGISTRY_ORG}" ]
        then
            echo "ERROR: Non-production release is being created but not all required BETA environment variables have been setup"
            echo "       Required variables are: BETA_REGISTRY_USERNAME, BETA_REGISTRY_PASSWORD and BETA_REGISTRY_ORG"
            exit 1
        else
            export IMAGE_REGISTRY_USERNAME="${BETA_REGISTRY_USERNAME}"
            export IMAGE_REGISTRY_PASSWORD="${BETA_REGISTRY_PASSWORD}"
            export IMAGE_REGISTRY_ORG="${BETA_REGISTRY_ORG}"
        fi
    fi
fi


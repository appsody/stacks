#!/bin/bash
set -e

# You can set the following environment variables to specify your docker credentials or docker registry: DOCKER_PASSWORD, DOCKER_USERNAME and DOCKER_REGISTRY

#this is the default list of repos that we need to build index for
if [ -z "$REPO_LIST" ]; then
    export REPO_LIST="experimental incubator stable"
fi

# dockerhub org for publishing stack
if [ -z $DOCKERHUB_ORG ]; then
    export DOCKERHUB_ORG=appsody
fi

# url for downloading released assets
if [ -z $RELEASE_URL ]; then
    export RELEASE_URL="https://github.com/$TRAVIS_REPO_SLUG/releases/download"
fi
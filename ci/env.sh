#!/bin/bash
set -e

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
#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# You can set the following environment variables to specify your docker credentials or docker registry: DOCKER_PASSWORD, DOCKER_USERNAME and DOCKER_REGISTRY

# If you would like to generate the Codewind index, set the environment variable CODEWIND_INDEX to 'true'
# You will need to download the PyYaml module to generate this file

#expose an extension point for running before main 'env' processing
if [ -f $base_dir/ci/ext/pre_env.sh ]
then
    . $base_dir/ci/ext/pre_env.sh
fi

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

#expose an extension point for running after main 'env' processing
if [ -f $base_dir/ci/ext/post_env.sh ]
then
    . $base_dir/ci/ext/post_env.sh
fi

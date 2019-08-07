#!/bin/bash
set -e

if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

if [ -z $REPO_LIST ]
then
    REPO_LIST="experimental incubator stable"
fi

# dockerhub org for publishing stack
if [ -z $DOCKERHUB_ORG ]
then
    export DOCKERHUB_ORG=appsody
fi

# url for downloading released assets
if [ -z $RELEASE_URL ]
then
    RELEASE_URL="https://github.com/$TRAVIS_REPO_SLUG/releases/download"
fi

if [ -z $STACK_LIST ]
then
    . $base_dir/ci/list.sh $base_dir
fi

. $base_dir/ci/package.sh $base_dir
. $base_dir/ci/test.sh $base_dir
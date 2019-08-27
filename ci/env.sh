#!/bin/bash
set -e

export script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export base_dir=$(cd "${script_dir}/.." && pwd)
export assets_dir="${script_dir}/assets"
export build_dir="${script_dir}/build"

mkdir -p $assets_dir
mkdir -p $build_dir

# Docker credentials for publishing images:
# export DOCKER_USERNAME
# export DOCKER_PASSWORD
# export DOCKER_REGISTRY

# Organization for Docker images
# export DOCKERHUB_ORG=appsody

# List of apposdy repositories to build indexes for
# export REPO_LIST="experimental incubator stable"

# git information (determined from current branch if unspecified)
# export GIT_BRANCH
# export GIT_ORG_REPO=appsody/stacks

# External/remote URL for downloading git released assets
# export RELEASE_URL=https://github.com/$GIT_ORG_REPO/releases/download

# Create template archive if it is missing
# export PACKAGE_WHEN_MISSING=true

# Name of appsody-index image (ci/package.sh)
# export INDEX_IMAGE=appsody-index

# Version or snapshot identifier for appsody-index (ci/package.sh)
# export INDEX_VERSION=SNAPSHOT

# List of current appsody index urls (space separated)
# export INDEX_LIST=https://github.com/appsody/stacks/releases/latest/download/incubator-index.yaml

# Base nginx image for appsody-index (ci/nginx/Dockerfile)
# export NGINX_IMAGE=nginx:stable-alpine

# Build the Codewind index when the value is 'true' (requires PyYaml)
# export CODEWIND_INDEX


#expose an extension point for running before main 'env' processing
if [ -f $script_dir/ext/pre_env.sh ]
then
    . $script_dir/ext/pre_env.sh
fi

#this is the default list of repos that we need to build index for
if [ -z "$REPO_LIST" ]; then
    export REPO_LIST="experimental incubator stable"
fi

# dockerhub org for publishing stack
if [ -z $DOCKERHUB_ORG ]
then
    export DOCKERHUB_ORG=appsody
fi

if [ -z $GIT_BRANCH ]
then
    if [ -z $TRAVIS_BRANCH ]
    then
        export GIT_BRANCH=$(git for-each-ref --format='%(refname:lstrip=2)' "$(git symbolic-ref -q HEAD)")
    else
        export GIT_BRANCH=${TRAVIS_BRANCH}
    fi
fi

# find github repository slug
if [ -z $GIT_ORG_REPO ]
then
    if [ -z "$TRAVIS_REPO_SLUG" ]
    then
        # Find git organization for the current branch
        git_remote=$(git for-each-ref --format='%(upstream:remotename)' "$(git symbolic-ref -q HEAD)")
        git_remote=${git_remote:-origin}

        git_remote_url=$(git remote get-url $git_remote)
        git_remote_url=${git_remote_url:-https://github.com/appsody/stacks.git}
        git_remote_url=${git_remote_url#*:}

        git_repo=$(basename $git_remote_url .git)
        git_repo=${git_repo:-stacks}

        git_org=$(basename $(dirname $git_remote_url))
        git_org=${git_org:-appsody}

        export GIT_ORG_REPO=$git_org/$git_repo
    else
        export GIT_ORG_REPO=$TRAVIS_REPO_SLUG
    fi
fi

if [ -z "$RELEASE_URL" ]
then
    # url for downloading git released assets
    export RELEASE_URL="https://github.com/$GIT_ORG_REPO/releases/download"
fi

if [ -z "$PACKAGE_WHEN_MISSING" ]
then
    export PACKAGE_WHEN_MISSING=true
fi

if [ -z "$INDEX_IMAGE" ]
then
    export INDEX_IMAGE=appsody-index
fi

if [ -z "$INDEX_VERSION" ]
then
    if [ -z $TRAVIS_BUILD_NUMBER ]
    then
        export INDEX_VERSION=SNAPSHOT
    else
        export INDEX_VERSION=${TRAVIS_BUILD_NUMBER}
    fi
fi

if [ -z "$INDEX_LIST" ]
then
    for repo_name in $REPO_LIST
    do
        INDEX_LIST+=("https://github.com/appsody/stacks/releases/latest/download/$repo_name-index.yaml")
    done
    export INDEX_LIST=${INDEX_LIST[@]}
fi

#expose an extension point for running after main 'env' processing
if [ -f $script_dir/ext/post_env.sh ]
then
    . $script_dir/ext/post_env.sh
fi

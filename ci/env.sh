#!/bin/bash
set -e

if [ ! -z "$assets_dir" ]
then
    return 0
fi

export script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export base_dir=$(cd "${script_dir}/.." && pwd)
export assets_dir="${script_dir}/assets"
export build_dir="${script_dir}/build"

mkdir -p $assets_dir
mkdir -p $build_dir


# ENVIRONMENT VARIABLES for controlling behavior of build, package, and release

# Publish images to image registry
# export IMAGE_REGISTRY_PUBLISH=false

# Credentials for publishing images:
# export IMAGE_REGISTRY
# export IMAGE_REGISTRY_USERNAME
# export IMAGE_REGISTRY_PASSWORD

# Organization for images
# export IMAGE_REGISTRY_ORG=appsody

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

# Use buildah instead of docker to build and push docker images when the value is true
# export USE_BUILDAH=false

# Build the Codewind index when the value is 'true' (requires PyYaml)
# export CODEWIND_INDEX

exec_hooks() {
    local dir=$1
    if [ -d $dir ]
    then
        echo "Running $(basename $dir) scripts"
        for x in $dir/*
        do
            if [ -x $x ]
            then
                . $x
            else
                echo skipping $(basename $x)
            fi
        done
    fi
}


#expose an extension point for running before main 'env' processing
exec_hooks $script_dir/ext/pre_env.d

#this is the default list of repos that we need to build index for
if [ -z "$REPO_LIST" ]; then
    export REPO_LIST="experimental incubator stable"
fi

# image registry org for publishing stack
if [ -z "$IMAGE_REGISTRY_ORG" ]
then
    export IMAGE_REGISTRY_ORG=mhamwala
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

if [ -z "$USE_BUILDAH" ]
then
    export USE_BUILDAH=false
fi

if [ -z "$IMAGE_REGISTRY_PUBLISH" ]
then
    if [ -z "$TRAVIS_TAG" ]
    then
        export IMAGE_REGISTRY_PUBLISH=false
    else
        export IMAGE_REGISTRY_PUBLISH=true
    fi
fi

image_build() {
    if [ "$USE_BUILDAH" == "true" ]; then
        buildah bud $@
    else
        docker build $@
    fi
}

image_tag() {
    if [ "$USE_BUILDAH" == "true" ]; then
        buildah tag $1 $2
    else
        docker tag $1 $2
    fi
}

image_push() {
    if [ "$IMAGE_REGISTRY_PUBLISH" == "true" ]
    then
        local name=$@
        if [ -n "$IMAGE_REGISTRY" ]
        then
            echo "Tagging ${IMAGE_REGISTRY}/$name"
            image_tag $name ${IMAGE_REGISTRY}/$name

            name=${IMAGE_REGISTRY}/$name
        fi

        echo "Pushing $name"
        if [ "$USE_BUILDAH" == "true" ]; then
            buildah push --tls-verify=false $name
        else
            docker push $name
        fi
    else
        echo "IMAGE_REGISTRY_PUBLISH=${IMAGE_REGISTRY_PUBLISH}; Skipping push of $@"
    fi
}

image_registry_login() {
    if [ "$IMAGE_REGISTRY_PUBLISH" == "true" ] && [ -n "$IMAGE_REGISTRY_PASSWORD" ]
    then
        if [ "$USE_BUILDAH" == "true" ]
        then
            echo "$IMAGE_REGISTRY_PASSWORD" | buildah login -u "$IMAGE_REGISTRY_USERNAME" --password-stdin "$IMAGE_REGISTRY"
        else
            echo "$IMAGE_REGISTRY_PASSWORD" |  docker login -u "$IMAGE_REGISTRY_USERNAME" --password-stdin "$IMAGE_REGISTRY"
        fi

        if [ $? -ne 0 ]
        then
            echo "ERROR: Registry login failed. Will not push images to registry."
            export IMAGE_REGISTRY_PUBLISH=false
        fi
    fi
}

#expose an extension point for running after main 'env' processing
exec_hooks $script_dir/ext/post_env.d

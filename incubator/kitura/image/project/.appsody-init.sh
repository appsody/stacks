#!/bin/bash
#
# Create local copy of package dependencies to enable building and code
# completion while developing locally.
#
set -e

# TODO: This should be a reference to the project's stack image
IMAGE="appsody/kitura"

# Create a temporary container in order to copy files from the stack image
docker create --name kitura-image-temp $IMAGE >/dev/null

# Current directory is .appsody-init, which is a child of the user's
# project directory, so we copy the dependencies to a .appsody directory
# one level up.
docker cp kitura-image-temp:/project/deps ../.appsody

docker rm kitura-image-temp >/dev/null

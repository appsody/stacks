#!/bin/bash
set -e

IMAGE="appsody/kitura"

# Create local copy of package dependencies to enable building locally.
docker create --name kitura-image-temp $IMAGE >/dev/null
docker cp kitura-image-temp:/project/deps ../.appsody
docker rm kitura-image-temp >/dev/null

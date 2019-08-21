#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

. $base_dir/ci/env.sh

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets

if [ -f $assets_dir/incubator-index.yaml ]; then
    mv $assets_dir/incubator-index.yaml $assets_dir/kabanero.yaml
fi

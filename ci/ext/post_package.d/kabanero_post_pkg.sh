#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../env.sh

if [ -f $base_dir/ci/ext/add_collections.sh ]
then
    . $base_dir/ci/ext/add_collections.sh $base_dir
fi

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets

if [ -f $assets_dir/incubator-index.yaml ]; then
    mv $assets_dir/incubator-index.yaml $assets_dir/kabanero-index.yaml
fi

if [ -f $assets_dir/incubator-index-local.yaml ]; then
    mv $assets_dir/incubator-index-local.yaml $assets_dir/kabanero-index-local.yaml
fi

if [ -f $assets_dir/incubator-index.json ]; then
    mv $assets_dir/incubator-index.json $assets_dir/kabanero-index.json
fi

index_src=$base_dir/ci/build/index-src
if [ -f $index_src/incubator-index.yaml ]; then
    mv $index_src/incubator-index.yaml $index_src/kabanero-index.yaml
fi

NGINX_IMAGE=nginx-ubi
image_build -t $NGINX_IMAGE \
 -f $script_dir/nginx-ubi/Dockerfile $script_dir

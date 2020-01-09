#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../env.sh

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

echo "BUILDING: $NGINX_IMAGE" > ${build_dir}/image.$NGINX_IMAGE.log
NGINX_IMAGE=nginx-ubi
if image_build ${build_dir}/image.$NGINX_IMAGE.log -t $NGINX_IMAGE \
 -f $script_dir/nginx-ubi/Dockerfile $script_dir
then
    echo "created $NGINX_IMAGE"
    trace "${build_dir}/image.$NGINX_IMAGE.log"
else
    stderr "${build_dir}/image.$NGINX_IMAGE.log"
    stderr "failed building $NGINX_IMAGE"
    exit 1
fi
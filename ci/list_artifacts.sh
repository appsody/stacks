#!/bin/bash

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

echo "Assets in /ci/assets are:"
echo "-------------------------------"
ls -al $base_dir/ci/assets
echo "-------------------------------"

echo "Content of index file is:"
echo "-------------------------------"
cat $base_dir/ci/assets/kabanero-index.yaml
echo "-------------------------------"

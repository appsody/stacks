#!/bin/bash
set -e

#if [ "${BUILD_ALL}" == "true" ]
#then
    if [ -z $RELEASE_NAME ]; then 
        if [ -z $TRAVIS_TAG ]; then
            if [ -f $base_dir/VERSION ]; then
                export RELEASE_NAME="$(cat $base_dir/VERSION)"
            fi
        else
            export RELEASE_NAME=$TRAVIS_TAG
        fi
    fi
#fi

if [ -z $ASSET_LIST ]; then
    asset_list="pipelines dashboards deploys"
else 
    asset_list=$ASSET_LIST
fi

export COPYFILE_DISABLE=1

mkdir -p $HOME/.appsody/stacks/dev.local
if [ -z $OVERRIDE_INDEX_LIST ]; then
    export INDEX_LIST=$RELEASE_URL/../latest/download/kabanero-index.yaml
else
    export INDEX_LIST=$OVERRIDE_INDEX_LIST
fi

retcode=0
curl -f -s -L $INDEX_LIST -o $HOME/.appsody/stacks/dev.local/incubator-index.yaml || retcode=$?
if [ $retcode != 0 ]; then
    echo "Curl for $INDEX_LIST failed"
    echo "apiVersion: v2" > $HOME/.appsody/stacks/dev.local/incubator-index.yaml
    echo "stacks:" >> $HOME/.appsody/stacks/dev.local/incubator-index.yaml
fi

#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../env.sh

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets
mkdir -p $assets_dir

# url for downloading released assets
release_url="https://github.com/$TRAVIS_REPO_SLUG/releases/download"

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        index_file_v2=$assets_dir/$repo_name-index.yaml
        index_file_local_v2=$assets_dir/$repo_name-index-local.yaml
        index_file_v2_temp=$assets_dir/$repo_name-index-temp.yaml
        nginx_file=$base_dir/ci/build/index-src/$repo_name-index.yaml
        
        if [ -f $index_file_v2 ]; then
            # Copy index file as we will update later
            cp $index_file_v2 $index_file_v2_temp
            
            # Resolve external URL for local / github release
            sed -e "s|${RELEASE_URL}/.*/|file://$assets_dir/|" $index_file_v2_temp > $index_file_local_v2
            if [ "${BUILD_ALL}" == "true" ]; then
                sed -e "s|${RELEASE_URL}/.*/|${RELEASE_URL}/${RELEASE_NAME}/|" $index_file_v2_temp > $index_file_v2
            fi
            rm -f $base_dir/ci/build/index-src/*.yaml
            sed -e "s|${RELEASE_URL}/.*/|{{EXTERNAL_URL}}/|" $index_file_v2_temp > $nginx_file
            rm -f $index_file_v2_temp
       fi
    else
        echo "SKIPPING: $repo_dir"
    fi
done

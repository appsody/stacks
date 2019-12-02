#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../env.sh

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets

asset_types="triggers"
asset_type="${asset_types%?}"

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "Processing triggers in collections repo: $repo_name"

        index_file=$assets_dir/$repo_name-index.yaml
        index_file_local=$assets_dir/$repo_name-index-local.yaml
        nginx_file=$base_dir/ci/build/index-src/$repo_name-index.yaml
        asset_dir=$base_dir/$repo_name/$asset_types
        
        if [ -d $asset_dir ]; then
            # check to see whether we have any files or sub-directories in the directory
            if [ -n "$(ls -A $asset_dir 2>/dev/null)" ]; then
                # We have some files or sub-directories in the directory
                # so we need to process this directory
                echo "$asset_types:" >> $index_file

                # Determine the asset tar.gz filename to be used 
                # to contain all of the asset files
                asset_archive=$repo_name.$asset_type.tar.gz

                # Create the triggers tar.gz file 
                COPYFILE_DISABLE=1; export COPYFILE_DISABLE
                tar -czf $assets_dir/$asset_archive -C $asset_dir .

                # Add details of the asset tar.gz into the index file
                echo "- id: $repo_name"  >> $index_file
                echo "  url: $RELEASE_URL/$RELEASE_NAME/$asset_archive" >> $index_file
                if [ -f $assets_dir/$asset_archive ]; then
                    sha256=$(cat $assets_dir/$asset_archive | $sha256cmd | awk '{print $1}')
                    echo "  sha256: $sha256" >> $index_file
                fi
            fi
        fi
    fi
    sed -e "s|${RELEASE_URL}/.*/|file://$assets_dir/|" $index_file > $index_file_local
    sed -e "s|${RELEASE_URL}/.*/|{{EXTERNAL_URL}}/|" $index_file > $nginx_file
done

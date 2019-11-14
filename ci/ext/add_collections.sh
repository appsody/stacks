#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets
mkdir -p $assets_dir

# url for downloading released assets
release_url="https://github.com/$TRAVIS_REPO_SLUG/releases/download"

if [[ "$OSTYPE" == "darwin"* ]]; then
    sha256cmd="shasum --algorithm 256"    # Mac OSX
else
    sha256cmd="sha256sum "  # other OSs
fi

build_asset_tar () {
    asset_build=$assets_dir/asset_temp
    mkdir -p $asset_build
    
    # copy all the files from the assets directoty to a build directory
    cp -r $1/* $asset_build

    # Generate a manifest.yaml file for each file in the tar.gz file
    asset_manifest=$asset_build/manifest.yaml
    echo "contents:" > $asset_manifest
    
    # for each of the assets generate a sha256 and add it to the manifest.yaml
    for asset_path in $(find $asset_build -type f -name '*')
    do
        asset_name=${asset_path#$asset_build/}
        if [ -f $asset_path ] && [ "$(basename -- $asset_path)" != "manifest.yaml" ]
        then
            sha256=$(cat $asset_path | $sha256cmd | awk '{print $1}')
            echo "- file: $asset_name" >> $asset_manifest
            echo "  sha256: $sha256" >> $asset_manifest
        fi
    done
    
    # build template archives
    tar -czf $assets_dir/$2 -C $asset_build .
    echo -e "--- Created $asset_type archive: $2"
    rm -fr $asset_build
}

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing collections repo: $repo_name"

        for asset in $asset_list
        do
            asset_type="${asset%?}"
            if [ -d $base_dir/$repo_name/common/$asset ]; then
                #echo "We have some common $asset to process"
                for asset_dir in $base_dir/$repo_name/common/$asset/*/
                do
                    if [ -d $asset_dir ]
                    then
                        # determine the assest id based on the subdirectory 
                        asset_id=$(basename $asset_dir)
            
                        # Determine the asset tar.gz filename to be used 
                        # to contain all of the asset files
                        asset_archive=$repo_name.common.$asset_type.$asset_id.tar.gz
                        build_asset_tar $asset_dir $asset_archive
                   fi
              done
            fi
        done

        index_file_v2=$assets_dir/$repo_name-index.yaml
        index_file_local_v2=$assets_dir/$repo_name-index-local.yaml
        index_file_v2_temp=$assets_dir/$repo_name-index-temp.yaml
        nginx_file=$base_dir/ci/build/index-src/$repo_name-index.yaml
        all_stacks=$assets_dir/all_stacks.yaml
        one_stack=$assets_dir/one_stack.yaml

        # count the number of stacks in the index file
        num_stacks=$(yq r $index_file_v2 stacks.[*].id | wc -l)
        
        # setup a yaml with just the stack info 
        # and new yaml with everything but stacks
        yq r $index_file_v2 stacks | yq p - stacks > $all_stacks
        yq d $index_file_v2 stacks > $index_file_v2_temp

        # iterate over each stack
        for stack in $repo_dir/*/stack.yaml
        do
            stack_dir=$(dirname $stack)
            
            if [ -d $stack_dir ]
            then
                stack_id=$(basename $stack_dir)
                
                # check if the stack needs to be built
                build=true
                for excluded_stack in $EXCLUDED_STACKS
                do
                    if [ $excluded_stack = $repo_name/$stack_id ]
                    then
                        build=false
                    fi
                done

                if [ $build = true ];  then
                    echo "Building collection: $repo_name/$stack_id"

                    stack_version=$(awk '/^version *:/ { gsub("version:","",$NF); gsub("\"","",$NF); print $NF}' $stack)
                    collection=$stack_dir/collection.yaml

                    count=0
                    stack_to_use=-1
                    while [ $count -lt $num_stacks ]
                    do
                        if [ $stack_id == $(yq r $all_stacks stacks.[$count].id) ]
                        then
                            stack_to_use=$count
                            break;
                        fi
                        count=$(( $count + 1 ))
                    done
                    if [ $stack_to_use -ge 0 ]
                    then
                        yq r $all_stacks stacks.[$stack_to_use] > $one_stack
                        if [ -f $collection ]
                        then
                            if [ -f $base_dir/ci/ext/add_collection_resources.sh ]
                            then
                                . $base_dir/ci/ext/add_collection_resources.sh $base_dir $stack_dir $stack_version $repo_name $one_stack
                            fi
                        fi
                        yq p -i $one_stack stacks.[+]
                        yq m -a -i $index_file_v2_temp $one_stack
                    fi
                    if [ -f $one_stack ]
                    then
                        rm -f $one_stack
                    fi
                fi
            fi
        done
        if [ -f $index_file_temp ]; then
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
    if [ -f $all_stacks ]
    then
        rm -f $all_stacks
    fi
done

#!/bin/bash
set -e

base_dir=$1
stack_dir=$2
stack_version=$3
repo_name=$4
index_file=$5
assets_dir=$base_dir/ci/assets
#assets_dir="/Users/stevengroeger/.appsody/stacks/kabanero"
stack_id=$(basename $stack_dir)
collection=$stack_dir/collection.yaml
collection_temp=$stack_dir/collection_temp.yaml
collection_temp2=$stack_dir/collection_temp2.yaml

. $base_dir/ci/env.sh

process_assets () {
    asset_types=$1
    asset_type="${asset_types%?}"

    #check to see whether we have a directory for the specific asset
    if [ -d $stack_dir/$asset_types ]
    then
        added_asset_type=0

        # For all of the assets get the list of subdirectories
        # these will be the different grouping of the assets, ie default, prototype
        for asset_dir in $stack_dir/$asset_types/*/
        do
            if [ -d $asset_dir ]
            then
                # only process if the directory is not empty
                if [ ! -z "$(ls -A -- "$asset_dir")" ]; then
                    # if we havent added the asset_type to the index then add it
                    if [ $added_asset_type -eq 0 ]; then
                        # put the asset_types value into the yaml, ie pipelines:
                        echo "$asset_types:" >> $index_file
                        added_asset_type=1
                    fi
                    # determine the assest id based on the subdirectory
                    asset_id=$(basename $asset_dir)

                    # Determine the asset tar.gz filename to be used
                    # to contain all of the asset files
                    asset_archive=$repo_name.$stack_id.v$stack_version.$asset_type.$asset_id.tar.gz
#                    asset_archive=$stack_id.v$stack_version.$asset_type.$asset_id.tar.gz

                    # Only process the assets if we are building
                    if [ $build = true ]
                    then
                        build_asset_tar $asset_dir $asset_archive
                    fi

                    # Add details of the asset tar.gz into the index file
                    echo "- id: $asset_id" >> $index_file
                    echo "  url: $RELEASE_URL/$stack_id-v$stack_version/$asset_archive" >> $index_file
#                    echo "  url: file://$assets_dir/$stack_id-v$stack_version/$asset_archive" >> $index_file
                    if [ -f $assets_dir/$asset_archive ]
                    then
                        sha256=$(cat $assets_dir/$asset_archive | $sha256cmd | awk '{print $1}')
                        echo "  sha256: $sha256" >> $index_file
                    fi
                fi
            fi
        done

        if [ -d $base_dir/$repo_name/common/$asset_types ]; then
            for asset_dir in $base_dir/$repo_name/common/$asset_types/*/
            do
                if [ -d $asset_dir ]
                then
                    # if we havent added the asset_type to the index then add it
                    if [ $added_asset_type -eq 0 ]; then
                        # put the asset_types value into the yaml, ie pipelines:
                        echo "$asset_types:" >> $index_file
                        added_asset_type=1
                    fi
                    # determine the assest id based on the subdirectory
                    asset_id=$(basename $asset_dir)

                    # Determine the asset tar.gz filename to be used
                    # to contain all of the asset files
                    asset_archive=$repo_name.common.$asset_type.$asset_id.tar.gz
#                    asset_archive=common.$asset_type.$asset_id.tar.gz

                    # Add details of the asset tar.gz into the index file
                    echo "- id: $asset_id" >> $index_file
                    echo "  url: $RELEASE_URL/$stack_id-v$stack_version/$asset_archive" >> $index_file
#                    echo "  url: file://$assets_dir/$asset_archive" >> $index_file
                    if [ -f $assets_dir/$asset_archive ]
                    then
                        sha256=$(cat $assets_dir/$asset_archive | $sha256cmd | awk '{print $1}')
                        echo "  sha256: $sha256" >> $index_file
                    fi
                fi
            done
        fi
    fi
}

if [ -f $collection ]
then
    # check to see if we have maintainers in the collection.yaml
    # if we do then we need to remove the maintainers from the
    # index file before merging the collection.yaml, otherwise
    # retain the maintainers from the index file
    if [ "$(yq r $collection stacks.[0].maintainers)" != "null" ]; then
        yq d -i $index_file stacks.[0].maintainers
    fi

    # Replace the IMAGE_REGISTRY_ORG placeholder with the actual value of the env var
    # and store into a temporary file for use in merging into kabanero-index.yaml
    sed -e "s|\$IMAGE_REGISTRY_ORG|${IMAGE_REGISTRY_ORG}|" -e "s|\$IMAGE_REGISTRY|${IMAGE_REGISTRY}|" $collection > $collection_temp

    # Merge the collection yaml file into the index file
    yq m -x -i $index_file $collection_temp

    # Remove the temporary file
    rm -fr $collection_temp

    # find the name of the default image in the collection.yaml
    default_imageId=$(yq r $index_file default-image)
    imagesCount=$(yq r $index_file images | awk '$1 == "-" { count++ } END { print count }')
    count=0
    while [ $count -lt $imagesCount ]
    do
        imageId=$(yq r $index_file images.[$count].id)
        if [ $default_imageId == $imageId ]
        then
            default_image=$(yq r $index_file images.[$count].image)
        fi
        count=$(( $count + 1 ))
    done

    # for each of the appsody templates we need to update the .appsody_config.yaml
    # file to contain the correct docker image name that is specified for the image
#    for template_dir in $stack_dir/templates/*/
#    do
#        if [ -d $template_dir ]
#        then
#            template_id=$(basename $template_dir)
#            template_archive=$repo_name.$stack_id.v$stack_version.templates.$template_id.tar.gz
##            template_archive=$stack_id.v$stack_version.templates.$template_id.tar.gz
#            template_temp=$assets_dir/tar_temp

#            mkdir -p $template_temp

#            # Update template archives
#            if [ -f $assets_dir/$template_archive ]; then
#                tar -xzf $assets_dir/$template_archive -C $template_temp
#                if [ -f $template_temp/.appsody-config.yaml ]
#                then
#                    yq w -i $template_temp/.appsody-config.yaml stack $default_image
#                else
#                    echo "stack: $default_image" > $template_temp/.appsody-config.yaml
#                fi
#                tar -czf $assets_dir/$template_archive -C $template_temp .
#                echo -e "--- Updated template archive: $template_archive"
#            fi

#            rm -fr $template_temp

#        fi
#    done
fi

#process the assets
for asset in $asset_list
do
    process_assets $asset
done

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

# iterate over each repo
for repo_name in $REPO_LIST
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing collections repo: $repo_name"

        index_file_v2=$assets_dir/$repo_name-index.yaml
        index_file_v2_temp=$assets_dir/$repo_name-index-temp.yaml
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
                build=false
                for repo_stack in $STACKS_LIST
                do
                    if [ $repo_stack = $repo_name/$stack_id ]
                    then
                        build=true
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
        mv $index_file_v2_temp $index_file_v2
    else
        echo "SKIPPING: $repo_dir"
    fi
    if [ -f $all_stacks ]
    then
        rm -f $all_stacks
    fi
done

#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../env.sh

assets_dir=$base_dir/ci/assets
kabanero_index_file=$assets_dir/kabanero-index.yaml
stack_content=$build_dir/stack_content.yaml

echo "Running xtract"
if [ -f $kabanero_index_file ]; then
  echo "extracting file $kabanero_index_file."
  # count the number of stacks in the index file
    num_stacks=$(yq r ${kabanero_index_file} stacks[*].name | wc -l)
    if [ $num_stacks -gt 0 ]
    then
      echo "Stack count: $num_stacks"
      for ((stack_count=0;stack_count<$num_stacks;stack_count++));
        do
            stack_id=$(yq r ${kabanero_index_file} stacks[$stack_count].id)
            stack_version=$(yq r ${kabanero_index_file} stacks[$stack_count].version)
            index_name=$stack_id-$stack_version-index.yaml
            index_file=$assets_dir/$index_name
            echo "stack index: $index_file"
            echo "apiVersion: v2" > $index_file
            echo "stacks:" >> $index_file
            yq r ${kabanero_index_file} stacks.[$stack_count] > $stack_content
            yq p -i $stack_content stacks.[+]
            yq m -a -i $index_file $stack_content
        done
    fi
else
  echo "Index file $kabanero_index_file not found for repo $repo_name."
fi

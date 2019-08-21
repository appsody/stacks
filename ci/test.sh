#!/bin/bash
set -e

if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# expose an extension point for running before main 'test' processing
if [ -f $base_dir/ci/ext/pre_test.sh ]
then
    . $base_dir/ci/ext/pre_test.sh $base_dir
fi

. $base_dir/ci/env.sh $base_dir

echo -e "\nNo tests implemented yet"

# expose an extension point for running after main 'test' processing
if [ -f $base_dir/ci/ext/post_test.sh ]
then
    . $base_dir/ci/ext/post_test.sh $base_dir
fi


#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'test' processing
if [ -f $script_dir/ext/pre_test.sh ]
then
    . $script_dir/ext/pre_test.sh $base_dir
fi

echo -e "\nNo tests implemented yet"

# expose an extension point for running after main 'test' processing
if [ -f $script_dir/ext/post_test.sh ]
then
    . $script_dir/ext/post_test.sh $base_dir
fi


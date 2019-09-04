#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'test' processing
exec_hooks $script_dir/ext/pre_test.d

echo -e "\nNo tests implemented yet"

# expose an extension point for running after main 'test' processing
exec_hooks $script_dir/ext/post_test.d


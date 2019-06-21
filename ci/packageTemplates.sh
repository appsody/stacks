#!/bin/bash

set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
  then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi
base_dir="$(cd "$1" && pwd)"
if ([ ! -d "$base_dir/stable" ] && [ ! -d "$base_dir/incubator" ]) || [ ! -d "$base_dir/ci" ]
then
    echo "Please ensure you pass the base dir of the stacks repository. $base_dir"
    exit 1
fi

package_dir=$base_dir/ci/package
mkdir -p $package_dir
base_dir_len=${#base_dir}+1

for template_dir in $base_dir/*/*/templates/*/
do
    echo Packaging $template_dir
    cd $template_dir
    filename=${template_dir:$base_dir_len}
    filename=${filename////.}tar.gz
    tar -cvzf $package_dir/$filename .
done
#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

if [ $# -gt 0 ]
then
    # ignore the old basedir argument
    dir=$1
    if [ -d $dir ] && [ -f $dir/RELEASE.md ]
    then
        shift
    fi
fi

# Allow multiple stacks to be selected
if [ $# -gt 0 ]
then
  export STACKS_LIST="$@"
  echo "STACKS_LIST=$STACKS_LIST"
fi

if [ -z "$STACKS_LIST" ]
then
  . $script_dir/list.sh
fi

. $script_dir/lint.sh
. $script_dir/prefetch.sh
. $script_dir/package.sh
. $script_dir/test.sh

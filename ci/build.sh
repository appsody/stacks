#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

if [ $# -gt 0 ]
then
    # ignore the old basedir argument
    dir=$(cd "$1" && pwd)
    if [ -f $dir/RELEASE.md ]
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
. $script_dir/package.sh
. $script_dir/test.sh

if [ "$CODEWIND_INDEX" == "true" ]; then
  python3 $script_dir/create_codewind_index.py
fi

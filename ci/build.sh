#!/bin/bash

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

# Fetch previously released stacks
if [ "$GENERATE_ALL_INDEXES" == "true" ]
then
  . $script_dir/prefetch.sh
fi

# Allow multiple stacks to be selected
if [ $# -gt 0 ]
then
  export STACKS_LIST="$@"
  echo "STACKS_LIST=$STACKS_LIST"

  for stack_name in $STACKS_LIST
  do
    if [ "${stack_name: -1}" == "/" ]
    then
      stack_name=${stack_name%?}
    fi
     
    stack_no_slash="$stack_no_slash $stack_name"
  done

  STACKS_LIST=$stack_no_slash
fi

. $script_dir/list.sh
. $script_dir/lint.sh
. $script_dir/package.sh
. $script_dir/test.sh

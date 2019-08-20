#!/bin/bash
set -e

if [ -z "$1" ]
then
  echo "One argument is required and must be the base directory of the repository."
  exit 1
fi

base_dir="$(cd "$1" && pwd)"

if [ ! -z "$2" ]
then
  export STACKS_LIST="$2"
fi


. $base_dir/ci/env.sh

if [ -z "$STACKS_LIST" ]
then
  . $base_dir/ci/list.sh $base_dir
else
  echo "STACKS_LIST=$STACKS_LIST"
fi
. $base_dir/ci/lint.sh $base_dir
. $base_dir/ci/package.sh $base_dir
. $base_dir/ci/test.sh $base_dir

if [ "$CODEWIND_INDEX" == "true" ]; then
  python3 $base_dir/ci/create_codewind_index.py $base_dir
fi

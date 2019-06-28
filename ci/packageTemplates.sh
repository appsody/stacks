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
index_v1=$package_dir/index.yaml
index_v2=$package_dir/index-v2.yaml

echo "apiVersion: v1
generated: $(date --iso-8601=seconds)
projects:" > $index_v1

echo "apiVersion: v2
generated: $(date --iso-8601=seconds)
stacks:" > $index_v2

for stack in $base_dir/*/*/stack.yaml
do
  if [[ $stack =~ "sample" ]]; then
    continue
  fi

  i=0
  stack_dir=$(dirname $stack)
  stack_id=$(cat $stack | grep ^id | cut -d' ' -f2)

  echo "  $stack_id:"    >> $index_v2
  sed 's/^/    /' $stack >> $index_v2
  echo "    templates:"  >> $index_v2

  echo "  $stack_id:"      >> $index_v1
  echo "  - created: $(date --iso-8601=seconds)" >> $index_v1
  sed 's/^/    /' $stack >> $index_v1
  echo "    urls:"       >> $index_v1

  for template_dir in $stack_dir/templates/*/
  do
    pushd $template_dir
    name=$(basename $template_dir)
    filename=${template_dir:$base_dir_len}
    filename=${filename////.}tar.gz

    echo "    - url: \"%PATH%/$filename\"" >> $index_v2
    echo "      name: $name" >> $index_v2

    if [ $i -eq 0 ]
    then
      echo "    - \"%PATH%/$filename\"" >> $index_v1
      ((i+=1))
    fi

    tar -cvz --exclude-from=$base_dir/.gitignore -f $package_dir/$filename .
    popd
  done
done


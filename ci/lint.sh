#!/bin/bash
set -e

if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the stack."
    exit 1
fi

fail=0

for stack_name in $STACKS_LIST
do
    root_dir="$(cd "$1" && pwd)/$stack_name"
    image_dir="$root_dir/image"
    project_dir="$image_dir/project"
    template_dir="$root_dir/templates/*"

    stackName=$(basename -- "$root_dir")
    ext="${stackName##*.}"
    stackName="${stackName%.*}"

    echo "LINTING $stackName"
    
    if [ ! "$(ls -A $root_dir)" ]
        then
            echo "This directory must contain: README, stack.yaml, image directory, and template directory"
            let "fail=fail+1"
    fi

    if [ ! -f $root_dir/stack.yaml ]
    then
        echo "Missing stack.yaml file in stack directory"
        let "fail=fail+1"

    elif [ ! -f $root_dir/README.md ]
    then
        echo "Missing README file in stack directory"
        let "fail=fail+1"
    fi

    if [ ! -f $image_dir/Dockerfile-stack ]
    then
        echo "Missing Dockerfile-stack in image directory"
        let "fail=fail+1"
    fi

    if [ ! -f $project_dir/Dockerfile ]
    then
        echo "Warning: No Dockerfile found in project directory"
    fi

    for templates in $template_dir
    do
        if [ ! -f $templates/.appsody-config.yaml ]
        then
            dirName=$(basename -- "$templates")
            extension="${dirName##*.}"
            dirName="${dirName%.*}"
            echo "No appsody config file found in template: $dirName"
            let "fail=fail+1"
        fi
    done

    if (($fail > 0));
    then
        echo "LINT TEST FAILED"
        exit 1
    else
        echo "LINT PASSED"
    fi
done

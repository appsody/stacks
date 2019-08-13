#!/bin/bash
set -e

echo ""

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
    stackName="${stackName%.*}"

    echo "LINTING $stackName"
    
    if [ ! "$(ls -A $root_dir)" ]
        then
            echo "This directory must contain: README, stack.yaml, image directory, and template directory"
            let "fail=fail+1"
    fi

    if [ ! -f $root_dir/stack.yaml ]
    then
        echo "MISSING stack.yaml file in stack directory"
        let "fail=fail+1"

    elif [ ! -f $root_dir/README.md ]
    then
        echo "MISSING README file in stack directory"
        let "fail=fail+1"
    fi

    if [ ! -f $image_dir/Dockerfile-stack ]
    then
        echo "MISSING Dockerfile-stack in image directory"
        let "fail=fail+1"
    fi

    if [ ! -d $project_dir ]
    then
        echo "MISSING project directory (Should be in image)"
        let "fail=fail+1"
    else
        if [ ! -f $project_dir/Dockerfile ]
        then
            echo "WARNING: No Dockerfile found in project directory"
        fi
    fi

    if [ ! -d "$root_dir/templates" ]
    then
        echo "No template directories exist (Should be in stack directory)"
        let "fail=fail+1"
    else
        for templates in $template_dir
        do
            if [ ! -f $templates/.appsody-config.yaml ]
            then
                dirName=$(basename -- "$templates")
                dirName="${dirName%.*}"
                echo "No appsody config file found in template: $dirName"
                let "fail=fail+1"
            fi
        done
    fi

    if (($fail > 0));
    then
        echo "LINT TEST FAILED"
        exit 1
    else
        echo "LINT PASSED"
        echo ""
    fi
done

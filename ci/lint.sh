#!/bin/bash
set -e

echo ""

if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

fail=0
warning=0

for stack_name in $STACKS_LIST
do
    stack_dir="$1/$stack_name"
    image_dir="$stack_dir/image"
    project_dir="$image_dir/project"
    template_dir="$stack_dir/templates/*"

    stackName=$(basename -- "$stack_dir")
    stackName="${stackName%.*}"

    echo "LINTING $stackName"

    if [ ! -f $stack_dir/stack.yaml ]
    then
        echo "ERROR: Missing stack.yaml file in $stack_dir"
        let "fail=fail+1"
    fi

    if [ ! -f $stack_dir/README.md ]
    then
        echo "ERROR: Missing README file in $stack_dir"
        let "fail=fail+1"
    fi

    if [ ! -d $image_dir ]
    then
        echo "ERROR: Missing image directory in $stack_dir"
        let "fail=fail+1"
    fi

    if [ ! -f $image_dir/Dockerfile-stack ]
    then
        echo "ERROR: Missing Dockerfile-stack in $image_dir"
        let "fail=fail+1"
    fi

    if [ ! -d $project_dir ]
    then
        echo "ERROR: Missing project directory in $image_dir"
        let "fail=fail+1"
    fi

    if [ ! -f $project_dir/Dockerfile ]
    then
        echo "WARNING: No Dockerfile found in $project_dir"
        let "warning=warning+1"
    fi

    if [ ! -d "$stack_dir/templates" ]
    then
        echo "ERROR: No template directory found in $stack_dir"
        let "fail=fail+1"
    fi

    for template_list in $template_dir
    do
        if [ ! -f $template_list/.appsody-config.yaml ]
        then
            templateName=$(basename -- "$template_list")
            templateName="${templateName%.*}"
            echo "No appsody config file found in template: $templateName"
            let "fail=fail+1"
        fi
    done

    if (($fail > 0));
    then
        echo "LINT TEST FAILED"
        echo ""
        echo "ERRORS: $fail"
        echo "WARNINGS: $warning"
        exit 1
    else
        echo "LINT TEST PASSED"
        echo ""
    fi
done

echo "WARNINGS: $warning"

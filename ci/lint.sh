#!/bin/bash
set -e

if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

error=0
warning=0
totalError=0
totalWarn=0

for stack_name in $STACKS_LIST
do
    stack_dir="$1/$stack_name"
    image_dir="$stack_dir/image"
    project_dir="$image_dir/project"
    template_dir="$stack_dir/templates/*"

    stackName=$(basename -- "$stack_dir")
    stackName="${stackName%.*}"

    echo -e "\nLINTING $stackName"

    if [ ! -f $stack_dir/stack.yaml ]
    then
        echo "ERROR: Missing stack.yaml file in $stack_dir"
        let "error=error+1"
    fi

    if [ ! -f $stack_dir/README.md ]
    then
        echo "ERROR: Missing README.md file in $stack_dir"
        let "error=error+1"
    fi

    if [ ! -d $image_dir ]
    then
        echo "ERROR: Missing image directory in $stack_dir"
        let "error=error+1"
    fi

    if [ ! -f $image_dir/Dockerfile-stack ]
    then
        echo "ERROR: Missing Dockerfile-stack in $image_dir"
        let "error=error+1"
    fi

    if [ ! -d $project_dir ]
    then
        echo "ERROR: Missing project directory in $image_dir"
        let "error=error+1"
    fi

    if [ ! -f $project_dir/Dockerfile ]
    then
        echo "WARNING: Missing Dockerfile in $project_dir"
        let "warning=warning+1"
    fi

    if [ ! -d "$stack_dir/templates" ]
    then
        echo "ERROR: Missing templates directory in $stack_dir"
        let "error=error+1"
    fi

    for template_list in $template_dir
    do
        if [ ! -f $template_list/.appsody-config.yaml ]
        then
            templateName=$(basename -- "$template_list")
            templateName="${templateName%.*}"
            echo "ERROR: Missing appsody config file in template: $project_dir/templates/$templateName"
            let "error=error+1"
        fi
    done

    if (($error > 0))
    then
        let "totalError=error+totalError"
        echo "LINT FAILED"
        echo "ERRORS: $error"
    else
        echo "LINT PASSED"
    fi

    if (($warning > 0))
    then
        let "totalWarn=warning+totalWarn"
        echo "WARNINGS: $warning"
    fi

    warning=0
    error=0
done

echo -e "\nTOTAL ERRORS: $totalError"
echo "TOTAL WARNINGS: $totalWarn"

if (($totalError > 0))
then
    echo "LINT FAILED: FIX ERRORS"
    exit 1
fi

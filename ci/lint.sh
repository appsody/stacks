#!/bin/bash

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

#expose an extension point for running before main 'lint' processing
exec_hooks $script_dir/ext/pre_lint.d

error=0
warning=0
totalError=0
totalWarn=0

for stack_name in $STACKS_LIST
do
    stack_dir="$base_dir/$stack_name"
    echo -e "\nLINTING: $stack_name"

    if [ ! -d $stack_dir ]
    then
        stderr "ERROR: Missing stack directory: $1/$stack_name"
        let "error=error+1"
    else
        image_dir="$stack_dir/image"
        project_dir="$image_dir/project"
        template_dir="$stack_dir/templates/*"

        if [ ! -f $stack_dir/stack.yaml ]
        then
            stderr "ERROR: Missing stack.yaml file in $stack_dir"
            let "error=error+1"
        fi

        if [ ! -f $stack_dir/README.md ]
        then
            stderr "ERROR: Missing README.md file in $stack_dir"
            let "error=error+1"
        fi

        if [ ! -d $image_dir ]
        then
            stderr "ERROR: Missing image directory in $stack_dir"
            let "error=error+1"
        fi

        if [ ! -f $image_dir/Dockerfile-stack ]
        then
            stderr "ERROR: Missing Dockerfile-stack in $image_dir"
            let "error=error+1"
        fi

        if [ ! -f $image_dir/LICENSE ]
        then
            stderr "ERROR: Missing LICENSE in $image_dir"
            let "error=error+1"
        fi

        if [ ! -d $project_dir ]
        then
            stderr "ERROR: Missing project directory in $image_dir"
            let "error=error+1"
        fi

        if [ ! -f $project_dir/Dockerfile ]
        then
            stderr "WARNING: Missing Dockerfile in $project_dir"
            let "warning=warning+1"
        fi

        if [ ! -d "$stack_dir/templates" ]
        then
            stderr "ERROR: Missing templates directory in $stack_dir"
            let "error=error+1"
        fi

        for template_list in $template_dir
        do
            if [ -f $template_list/.appsody-config.yaml ]
            then
                templateName=$(basename -- "$template_list")
                templateName="${templateName%.*}"
                stderr "ERROR: Unexpected appsody config file in template: $project_dir/templates/$templateName"
                let "error=error+1"
            fi
        done
      fi

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

#expose an extension point for running after main 'lint' processing
exec_hooks $script_dir/ext/post_lint.d

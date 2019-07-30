#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# check if running on travis pull request or not
if [ $TRAVIS_PULL_REQUEST ] && [ "$TRAVIS_PULL_REQUEST" != "false" ]
then
    # check for changed files
    CHANGED_FILES=$(git diff --name-only $TRAVIS_COMMIT_RANGE)

    for changed_stacks in $CHANGED_FILES
    do
        if [[ $changed_stacks == *stack.yaml ]]
        then
            var=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $changed_stacks`
            STACKS_LIST+=("$var")
        fi
    done
    echo "Generated list for new or modified stacks"
else
    # list of repositories to build indexes for
    repo_list="experimental incubator stable"

    for repo_name in $repo_list
    do
        repo_dir=$base_dir/$repo_name
        if [ -d $repo_dir ]
        then
            for stack_exists in $repo_dir/*/stack.yaml
            do
                if [ -f $stack_exists ]
                then
                    var=`echo $stack_exists | sed 's/.*stacks\///'`
                    split_stack=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $var`
                    STACKS_LIST+=("$split_stack")
                fi
            done
        fi
    done
    echo "Generated list for all stacks"
fi

# expose environment variable for stacks
export STACKS_LIST=${STACKS_LIST[@]}
echo "STACKS_LIST=$STACKS_LIST"
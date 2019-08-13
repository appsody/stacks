#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

. $base_dir/ci/env.sh

# check if running on travis pull request or not
if [ $TRAVIS_PULL_REQUEST ] && [ "$TRAVIS_PULL_REQUEST" != "false" ] || [ $TRAVIS_COMMIT_RANGE ]
then
    # check for changed files
    echo "Listing new/updated stacks in this pull request"
    CHANGED_FILES=$(git diff --name-only $TRAVIS_COMMIT_RANGE)

    for changed_stacks in $CHANGED_FILES
    do
        if [[ $changed_stacks == *stack.yaml ]]
        then
            var=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $changed_stacks`
            STACKS_LIST+=("$var")
        fi
    done
else

    if [ $TRAVIS_TAG ]
    then
        stack_id=`echo ${TRAVIS_TAG/-v[0-9]*/}`
        echo "Listing stacks for this release"
    else
        echo "Listing all stacks"
    fi

    for repo_name in $REPO_LIST
    do
        repo_dir=$base_dir/$repo_name
        if [ -d $repo_dir ]
        then
            for stack_exists in $repo_dir/*/stack.yaml
            do
                if [ -f $stack_exists ]
                then
                    var=`echo ${stack_exists#"$base_dir/"}`
                    repo_stack=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $var`
                    if [ $TRAVIS_TAG ] && [[ $repo_stack != */$stack_id ]]
                    then
                        continue;
                    fi
                    # list of repositories to build indexes for
                    STACKS_LIST+=("$repo_stack")
                fi
            done
        fi
    done
fi

# expose environment variable for stacks
export STACKS_LIST=${STACKS_LIST[@]}
echo "STACKS_LIST=$STACKS_LIST"

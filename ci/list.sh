#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

. $base_dir/ci/env.sh $base_dir

# expose an extension point for running beforer main 'list' processing
if [ -f $base_dir/ci/ext/pre_list.sh ]
then
    . $base_dir/ci/ext/pre_list.sh $base_dir
fi

# check if running on travis pull request or not
if [ -z $BUILD_ALL ] && ([ $TRAVIS_PULL_REQUEST ] && [ "$TRAVIS_PULL_REQUEST" != "false" ] || [ $TRAVIS_COMMIT_RANGE ])
then
    # check for changed files
    echo "Listing new/updated stacks in this pull request"
    CHANGED_FILES=$(git diff --name-only $TRAVIS_COMMIT_RANGE)

    for changed_stacks in $CHANGED_FILES
    do
        if [[ $changed_stacks == *stack.yaml ]] || [[ $changed_stacks == *collection.yaml ]]
        then
            var=`awk '{split($1, a, "/*"); print a[1]"/"a[2]}' <<< $changed_stacks`
            STACKS_LIST+=("$var")
        fi
    done
else

    # ignore TRAVIS_TAG if BUILD_ALL is set
    if [ $TRAVIS_TAG ] && [ -z $BUILD_ALL ]
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
                    if [ -z $BUILD_ALL ] && [ $TRAVIS_TAG ] && [[ $repo_stack != */$stack_id ]]
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


# expose an extension point for running after main 'list' processing
if [ -f $base_dir/ci/ext/post_list.sh ]
then
    . $base_dir/ci/ext/post_list.sh $base_dir 
fi

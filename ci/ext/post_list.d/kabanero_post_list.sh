#!/bin/bash
set -e

# if there are some stacks to exclude then 
# remove them all from the STACKS_LIST
if [ -n "$EXCLUDED_STACKS" ]; then

    echo "Excluding stacks $EXCLUDED_STACKS"
    stacks=$STACKS_LIST

    for full_excluded_stack in $EXCLUDED_STACKS
    do
        stacks=${stacks//$full_excluded_stack}
    done
    export STACKS_LIST=$stacks
    echo "New STACKS_LIST=$STACKS_LIST"
fi
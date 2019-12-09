#!/bin/bash

exit_script=0
for exe in "yq" "docker"
do
    if ! $exe --version > /dev/null 2>&1
    then
        echo "Error: '$exe' command is not installed or not available on the path"
        exit_script=1
    fi
done

if [ "$CODEWIND_INDEX" == "true" ]
then
    if ! python --version > /dev/null 2>&1
    then
        echo "Error: 'python' command is not installed or not available on the path"
        exit_script=1
    else
        if ! python -c "import yaml" > /dev/null 2>&1
        then
            echo "Error: Python 'yaml' package not installed"
            exit_script=1
        fi
    fi
fi


if [ $exit_script != 0 ]
then
    echo "Error: Some required dependancies are missing, exiting script"
    exit 1
fi
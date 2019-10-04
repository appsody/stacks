#!/bin/bash

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'test' processing
exec_hooks $script_dir/ext/pre_test.d

pull_policy=$APPSODY_PULL_POLICY

if ! which appsody > /dev/null
then
    echo "appsody CLI not found on the path"
    return 1
fi

wait_until_ready() {
    i=0
    while true
    do
        if eval $1
        then
            break
        else
            ((i=i+1))
            if [ $i -gt 60 ]
            then
                printf '\n'
                return 1
            fi
            printf '.'
            sleep 2s
        fi
    done
    printf '\n'
    return 0
}

test_template() {
    local template=$2
    local stack=$(basename $1)
    local index=$(dirname $1)-index
    local index_local=$(dirname $1)-index-local
    local error=0

    echo ""
    echo "=== Testing $stack : $template"
    echo ""

    if appsody list $index_local | grep -q $stack
    then
        local repo=$index_local
        export APPSODY_PULL_POLICY=IFNOTPRESENT
    else
        local repo=$index
        export APPSODY_PULL_POLICY=ALWAYS
    fi

    rm -rf $build_dir/test/$repo/$stack/$template
    mkdir -pv $build_dir/test/$repo/$stack/$template
    pushd $build_dir/test/$repo/$stack/$template

    echo ""
    echo "> appsody init $repo/$stack $template"
    echo ""
    if ${CI_WAIT_FOR} appsody init --overwrite $repo/$stack $template > init.log  2>&1
    then
        trace  "Output from appsody init" init.log

        echo ""
        echo "> appsody run -P --name $stack-$template"
        echo ""
        appsody run -P --name $stack-$template > run.log  2>&1 &

        echo "Waiting for container to start"
        if ! wait_until_ready "appsody ps | grep -q $stack-$template"
        then
            cat run.log
            ((error=error+1))
        fi
        echo error=$error
        appsody ps

        echo ""
        echo "> appsody stop --name $stack-$template"
        echo ""
        appsody stop --name $stack-$template
        if ! wait_until_ready "appsody ps | grep -q $stack-$template; [ \$? -eq 1 ]"
        then
            ((error=error+1))
        fi
        echo error=$error
        appsody ps

        trace "Output from appsody run" run.log

        echo ""
        echo "> appsody build"
        echo ""
        if ! ${CI_WAIT_FOR} appsody build > build.log  2>&1
        then
            ((error=error+1))
            cat build.log
        fi
        trace  "Output from appsody build" build.log
        echo error=$error
    else
        ((error=error+1))
        echo "Unable to initialize project"
        cat init.log
    fi

    if [ $error -gt 0 ]
    then
        echo "Finished with ${error} error(s)"
        exit 1
    fi
    popd
}

for x in $assets_dir/*.yaml
do
    if [ -f $x ] && grep template $x > /dev/null
    then
        index_url=file://$x
        y=$(basename $x)
        if appsody repo list | awk '{print $1}' | grep -q -e "${y%.*}$"
        then
            echo "Repo ${y%.*} exists"
        else
            echo "Installing repo ${y%.*} : $index_url"
            appsody repo add ${y%.*} $index_url
        fi
    fi
done

appsody repo list
export APPSODY_PULL_POLICY=IFNOTPRESENT

for stack in $STACKS_LIST
do
    for template in "$stack/templates/*"
    do
        test_template "$stack" "$(basename $template)"
    done
done

export APPSODY_PULL_POLICY=$pull_policy

# expose an extension point for running after main 'test' processing
exec_hooks $script_dir/ext/post_test.d

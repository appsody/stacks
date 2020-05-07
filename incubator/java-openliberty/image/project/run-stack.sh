#!/bin/bash

if [ $# -eq 0 ]; then
  echo "ERROR: no argument supplied to script"
  exit 1
fi
ACTION=$1

NOOP_APPSODY_DEV=
if [ -e /project/user-app/.appsody-nodev ]
then
    NOOP_APPSODY_DEV=1
fi

case $ACTION in
    prep)
        ../validate.sh dev
        ;;
    run)
        if [ ! -z $NOOP_APPSODY_DEV ]
        then
            echo appsody run/debug/test not supported when .appsody-nodev detected.
            exit 0
        else
            set -x
            mvn -B -Plocal-dev -DappsDirectory=apps -Ddebug=false -Dmaven.repo.local=/mvn/repository pre-integration-test liberty:dev
        fi
        ;;
    debug)
        if [ ! -z $NOOP_APPSODY_DEV ]
        then
            echo appsody run/debug/test not supported when .appsody-nodev detected.
            exit 0
        else
            set -x
            mvn -B -Plocal-dev -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository pre-integration-test liberty:dev
        fi
        ;;
    test)
        if [ ! -z $NOOP_APPSODY_DEV ]
        then
            echo appsody run/debug/test not supported when .appsody-nodev detected.
            exit 0
        else
            # Keep liberty:create before 'pre-integration-test' phase to be consistent with "Dockerfile" for 'appsody build'
            set -x
            mvn -B -Plocal-dev -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository clean liberty:create pre-integration-test liberty:install-feature liberty:start liberty:deploy failsafe:integration-test liberty:stop failsafe:verify
            # make sure exit code propagates
        fi
        ;;
    *)
        echo "ERROR: script called with unexpected argument: $1"
        exit 1
        ;;
esac

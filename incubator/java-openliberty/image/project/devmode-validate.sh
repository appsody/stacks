#!/bin/bash

NOOP_APPSODY_DEV=0

if [ -e /project/user-app/.appsody-nodev ]
then
	NOOP_APPSODY_DEV=1
fi

case $APPSODY_DEV_MODE in
	run)
		#if [ -e /project/user-app/.appsody-nodev ]
		if [ $NOOP_APPSODY_DEV = 1 ]
		then
			echo appsody run/debug/test not supported when .appsody-nodev detected.
			exit 1
		else
			mvn -B -Pstack-image-run -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository package liberty:dev
		fi
		;;
	debug)
		if [ $NOOP_APPSODY_DEV = 1 ]
		then
			echo appsody run/debug/test not supported when .appsody-nodev detected.
			exit 1
		else
			mvn -B -Pstack-image-run -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository package liberty:dev
		fi
		;;
	test)
		if [ $NOOP_APPSODY_DEV = 1 ]
		then
			echo appsody run/debug/test not supported when .appsody-nodev detected.
			exit 0
		else
			exec mvn -B -Pstack-image-run -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository clean package liberty:create liberty:install-feature liberty:start liberty:deploy failsafe:integration-test@it-exec liberty:stop failsafe:verify
		fi
		;;
esac
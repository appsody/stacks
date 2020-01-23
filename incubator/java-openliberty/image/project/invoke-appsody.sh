#!/bin/bash

if [ -e /project/user-app/.appsody-nolocal ]
then
	BIN_TEMPLATE=1
fi

case $APPSODY_DEV_MODE in
	run)
		#if [ -e /project/user-app/.appsody-nolocal ]
		if [ $BIN_TEMPLATE = 1 ]
		then
			exec echo this appsody run not supported when using binary template
		else
			mvn -B -Pstack-image-run -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository liberty:dev
		fi
		;;
	debug)
		if [ -e /project/user-app/.appsody-nolocal ]
		then
			echo appsody debug not supported when using binary template
		else
			mvn -B -Pstack-image-run -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository liberty:dev
		fi
		;;
	test)
		if [ -e /project/user-app/.appsody-nolocal ]
		then
			echo appsody test not supported when using binary template
		else
			exec mvn -B -Pstack-image-run -DappsDirectory=apps -Dmaven.repo.local=/mvn/repository clean package liberty:create liberty:install-feature liberty:start liberty:deploy failsafe:integration-test@it-exec liberty:stop failsafe:verify
		fi
		;;
esac
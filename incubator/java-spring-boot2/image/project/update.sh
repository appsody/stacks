#!/bin/bash

# This is the list of packages that are required for stack operation and may not be present
# in the base image. 
XTRAPKGS="curl wget xmlstarlet unzip ca-certificates"

UPDATE_SYSTEM=false

#
# Check for optional parameter indicating "update the system"
#
OPTS=`getopt -o s --long system -- "$@"`
[ $? != 0 ] && echo "ERROR Invalid parameter." >&2 && exit 1

eval set -- "$OPTS"

while true; do
  case "$1" in
    -s | --system ) UPDATE_SYSTEM=true; shift ;;
    -- ) shift; break ;;
    * ) echo "ERROR Invalid option \"$1\""; exit 1 ;;
  esac
done

echo UPDATE_SYSTEM=$UPDATE_SYSTEM


# 
# Do Debian or Red Hat
# 
which apt-get 2>&1 > /dev/null; USINGAPT=$?
if [ $USINGAPT = "0" ] ; then 
	apt-get -qq update || exit 1
	apt-get -qq install -y bash $XTRAPKGS || exit 1
	
	if [ $UPDATE_SYSTEM = "true" ]; then
      export DEBIAN_FRONTEND=noninteractive
	  apt-get -qq upgrade -y || exit 1
	fi
	
	apt-get -qq clean \
	  && rm -rf /tmp/* /var/lib/apt/lists/*
else
	EPEL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
	yum install --disableplugin=subscription-manager -y $EPEL || exit 1
	yum install --disableplugin=subscription-manager -y $XTRAPKGS || exit 1	   

	if [ $UPDATE_SYSTEM = "true" ]; then
	  yum upgrade --disableplugin=subscription-manager -y || exit 1
	fi

	yum clean --disableplugin=subscription-manager packages 	
fi  

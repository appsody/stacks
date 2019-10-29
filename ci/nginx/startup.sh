#!/bin/sh

CONF_FILE=
if echo $EXTERNAL_URL | grep https
then
    CONF_FILE="-c nginx-ssl.conf"
fi

# Replace the resource paths in index yaml files to match the specified external URL
find /opt/www/public -name '*.yaml' -exec sed -i -e "s|{{EXTERNAL_URL}}|${EXTERNAL_URL%/}|" {} \;

# Replace the resource paths in index json files to match the specified external URL
find /opt/www/public -name '*.json' -exec sed -i -e "s|{{EXTERNAL_URL}}|${EXTERNAL_URL%/}|" {} \;

if [ -z "${DRY_RUN}" ]
then
    exec nginx $CONF_FILE
else
    echo "Dry run"
    echo using $CONF_FILE
    echo user id is $(id -u)
    echo group id is $(id -g)
fi

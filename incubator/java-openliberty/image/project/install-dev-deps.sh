#!/bin/bash
mvn -Dmaven.repo.local=/mvn/repository dependency:copy-dependencies@copy-dropin dependency:copy-dependencies@copy-resource dependency:copy-dependencies@copy-asm -f /project/pom-dev.xml
mkdir -p /opt/ibm/wlp/usr/servers/defaultServer/configDropins/defaults
cp /project/server-dev.xml /opt/ibm/wlp/usr/servers/defaultServer/configDropins/defaults/server.xml

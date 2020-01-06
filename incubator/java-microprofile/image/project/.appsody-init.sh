#!/bin/bash

if [ ! -d ~/.m2/repository ]; then
  echo -e "Creating local maven repository:  ~/.m2/repository"
  mkdir -p ~/.m2/repository
fi

which java 2>&1 >/dev/null ; JAVA_KNOWN=$?
if [ ! -z "$JAVA_HOME" ] || [ $JAVA_KNOWN = "0" ]; then
  ./mvnw install -Denforcer.skip=true
fi
#!/bin/bash
which java 2>&1 >/dev/null ; JAVA_KNOWN=$?
if [ ! -z "$JAVA_HOME" ] || [ $JAVA_KNOWN = "0" ]; then
  ./mvnw install -Denforcer.skip=true
fi
#!/bin/bash

if [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && [ -x /usr/bin/tput ] && [[ `tput colors` != "0" ]]; then
  color_prompt="yes"
else
  color_prompt=
fi

if [[ "$color_prompt" == "yes" ]]; then
      BLUE="\033[0;34m"
  NO_COLOR="\033[0m"
else
        BLUE=""
  NO_COLOUR=""
fi

if [ ! -d ~/.m2/repository ]; then
  echo -e "${BLUE}Creating local maven repository:  ~/.m2/repository${NO_COLOR}"
  mkdir -p ~/.m2/repository
fi

which java 2>&1 >/dev/null ; JAVA_KNOWN=$?
if [ ! -z "$JAVA_HOME" ] || [ $JAVA_KNOWN = "0" ]; then
  ./mvnw install -Denforcer.skip=true
fi

# copy the maven wrapper from the stack to extracted application directory
cp -Rp mvnw* ..
cp -Rp .mvn ..

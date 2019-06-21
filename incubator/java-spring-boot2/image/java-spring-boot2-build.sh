#!/bin/bash
if [ -x /usr/bin/tput ] && [[ `tput colors` != "0" ]]; then
  color_prompt="yes"
elif [ -x /ffp/bin/tput ] && [[ `tput colors` != "0" ]]; then
  color_prompt="yes"
else
  color_prompt=
fi

if [[ "$color_prompt" == "yes" ]]; then
      BLUE="\033[0;34m"
    GREEN="\033[0;32m"
    WHITE="\033[1;37m"
      RED="\033[0;31m"
    YELLOW="\033[0;33m"
  NO_COLOR="\033[0m"
else
        BLUE=""
      GREEN=""
      WHITE=""
        RED=""
  NO_COLOUR=""
fi

run_mvn () {
  echo -e "${GREEN}> mvn $@${NO_COLOR}"
  mvn "$@"
}

note() {
  echo -e "${BLUE}$@${NO_COLOR}"
}

error() {
  echo -e "${RED}$@${NO_COLOR}"
}

common() {
  # Get parent pom information (appsody-boot2-pom.xml)
  args='export PARENT_GROUP_ID=${project.groupId}; export PARENT_ARTIFACT_ID=${project.artifactId}; export PARENT_VERSION=${project.version}'
  eval $(mvn -q -Dexec.executable=echo -Dexec.args="${args}" --non-recursive -f appsody-boot2-pom.xml exec:exec 2>/dev/null)

  # Install parent pom
  note "Installing parent ${PARENT_GROUP_ID}:${PARENT_ARTIFACT_ID}:${PARENT_VERSION}"
  run_mvn install -q -f appsody-boot2-pom.xml

  # Require parent in pom.xml
  if ! grep -Gzq "<parent.*${PARENT_GROUP_ID}.*${PARENT_ARTIFACT_ID}.*</parent" pom.xml
  then
    error "Project is missing required parent:

    <parent>
      <groupId>${PARENT_GROUP_ID}</groupId>
      <artifactId>${PARENT_ARTIFACT_ID}</artifactId>
      <version>${PARENT_VERSION}</version>
    </parent>"
    exit 1
  fi

  major=$(echo ${PARENT_VERSION} | cut -d'.' -f1)
  ((next=major+1))

  note "Updating parent version and resolving dependencies"
  run_mvn -q versions:update-parent "-DparentVersion=[${major},${next})" dependency:go-offline
}

recompile() {
  note "Compile project in the foreground"
  run_mvn compile
}

package() {
  note "Package project in the foreground"
  run_mvn clean package verify
}

debug() {
  note "Build and debug project in the foreground"
  run_mvn spring-boot:run -Dspring-boot.run.jvmArguments='-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005'
}

run() {
  note "Build and run project in the foreground"
  run_mvn clean -Dmaven.test.skip=true spring-boot:run
}

test() {
  note "Test project in the foreground"
  run_mvn package test
}

fail() {
  error "Unexpected script usage, expected one of recompile,package,debug,run or test"
}

#set the action, default to fail text if none passed.
ACTION=
if [ $# -ge 1 ]; then
  ACTION=$1
  shift
fi

case "${ACTION}" in
  recompile)
    recompile
  ;;
  package)
    common
    package
  ;;
  debug)
    common
    debug
  ;;
  run)
    common
    run
  ;;
  test)
    common
    test
  ;;  
  *)
    fail
  ;;
esac

#!/bin/bash
if [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && [ -x /usr/bin/tput ] && [[ `tput colors` != "0" ]]; then
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

note() {
  echo -e "${BLUE}$@${NO_COLOR}"
}
warn() {
  echo -e "${YELLOW}$@${NO_COLOR}"
}
error() {
  echo -e "${RED}$@${NO_COLOR}"
}

run_mvn () {
  echo -e "${GREEN}> mvn $@${NO_COLOR}"
  mvn "$@"
}

version() {
  # get version from specified POM
  xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t \
     -o "export GROUP_ID=" -v "/x:project/x:groupId" -n \
     -o "export ARTIFACT_ID=" -v "/x:project/x:artifactId" -n \
     -o "export VERSION=" -v "/x:project/x:version" \
     $1
}

common() {
  # workaround: exit with error if repository does not exist
  if [ ! -d /mvn/repository ]; then
    error "Could not find local Maven repository

    Create a .m2/repository directory in your home directory. For example:
    * linux:   mkdir -p ~/.m2/repository
    * windows: mkdir %SystemDrive%%HOMEPATH%\.m2\repository
    "
    exit 1
  fi

  # Get parent pom information (appsody-boot2-pom.xml)
  eval $(version appsody-boot2-pom.xml)

  # Install parent pom
  note "Installing parent ${GROUP_ID}:${ARTIFACT_ID}:${VERSION}"
  run_mvn install -q -f appsody-boot2-pom.xml

  local groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:groupId" pom.xml)
  local artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:artifactId" pom.xml)

  # Require parent in pom.xml
  if [ "${groupId}" != "${GROUP_ID}" ] || [ "${artifactId}" != "${ARTIFACT_ID}" ]; then
    error "Project is missing required parent:

    <parent>
      <groupId>${GROUP_ID}</groupId>
      <artifactId>${ARTIFACT_ID}</artifactId>
      <version>${VERSION}</version>
      <relativePath/>
    </parent>
    "
    exit 1
  fi

  major=$(echo ${VERSION} | cut -d'.' -f1)
  ((next=major+1))

  note "Updating parent version and resolving dependencies"
  run_mvn -q versions:update-parent "-DparentVersion=[${major},${next})" dependency:go-offline
  unset GROUP_ID ARTIFACT_ID VERSION
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
    error "Unexpected script usage, expected one of recompile, package, debug, run, test"
  ;;
esac

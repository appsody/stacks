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
  MVN_COLOR=""
else
        BLUE=""
      GREEN=""
      WHITE=""
        RED=""
   NO_COLOR=""
  MVN_COLOR="-Dstyle.color=never"
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
  mvn --no-transfer-progress ${MVN_COLOR} "$@"
}

exec_run_mvn () {
  echo -e "${GREEN}> mvn $@${NO_COLOR}"
  exec mvn --no-transfer-progress ${MVN_COLOR} "$@"
}

common() {
  # Test pom.xml is present and a file.
  if [ ! -f ./pom.xml ] && [ ! -z "${APPSODY_DEV_MODE}" ]; then
    error "Could not find Maven pom.xml

    * The project directory (containing an .appsody-conf.yaml file) must contain a pom.xml file.
    * On Windows and MacOS, the project directory should also be shared with Docker:
      - Win: https://docs.docker.com/docker-for-windows/#shared-drives
      - Mac: https://docs.docker.com/docker-for-mac/#file-sharing
    "
    exit 1
  fi
  # workaround: exit with error if repository does not exist
  if [ ! -d /mvn/repository ] && [ ! -z "${APPSODY_DEV_MODE}" ]; then
    error "Could not find local Maven repository

    Create a .m2/repository directory in your home directory. For example:
    * linux:   mkdir -p ~/.m2/repository
    * windows: mkdir %SystemDrive%%HOMEPATH%\.m2\repository
    "
    exit 1
  fi

  # Get parent pom information 
  local a_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:groupId" /project/{{.stack.parentpomfilename}})
  local a_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:artifactId" /project/{{.stack.parentpomfilename}})
  local a_version=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" /project/{{.stack.parentpomfilename}})
  local a_major=$(echo ${a_version} | cut -d'.' -f1)
  local a_minor=$(echo ${a_version} | cut -d'.' -f2)
  ((next=a_minor+1))
  local a_range="[${a_major}.${a_minor},${a_major}.${next})"

  if ! $(mvn -N dependency:get -q -o -Dartifact=${a_groupId}:${a_artifactId}:${a_version} -Dpackaging=pom >/dev/null)
  then
    # Install parent pom
    note "Installing parent ${a_groupId}:${a_artifactId}:${a_version} and required dependencies..."
    if [ -z "${APPSODY_DEV_MODE}" ]
    then
      run_mvn install -q -f /project/{{.stack.parentpomfilename}}
    else
      run_mvn install -f /project/{{.stack.parentpomfilename}}
    fi
  fi

  local p_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:groupId" pom.xml)
  local p_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:artifactId" pom.xml)
  local p_version_range=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:version" pom.xml)

  # Require parent in pom.xml
  if [ "${p_groupId}" != "${a_groupId}" ] || [ "${p_artifactId}" != "${a_artifactId}" ]; then
    error "Project pom.xml is missing the required parent:

    <parent>
      <groupId>${a_groupId}</groupId>
      <artifactId>${a_artifactId}</artifactId>
      <version>${a_range}</version>
      <relativePath/>
    </parent>
    "
    exit 1
  fi

  if ! /project/util/check_version contains "$p_version_range" "$a_version";  then
    error "Version mismatch

The version of the appsody stack '${a_version}' does not match the
parent version specified in pom.xml '${p_version_range}'. Please update
the parent version in pom.xml, and test your changes.

    <parent>
      <groupId>${a_groupId}</groupId>
      <artifactId>${a_artifactId}</artifactId>
      <version>${a_range}</version>
      <relativePath/>
    </parent>
    "
    exit 1
  fi
}

recompile() {
  note "Compile project in the foreground"
  exec_run_mvn compile 
}

package() {
  local group_id=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:groupId" pom.xml)
  local artifact_id=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:artifactId" pom.xml)
  local artifact_version=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" pom.xml)
  note "Packaging and verifying application ${group_id}:${artifact_id}:${artifact_version}"
  run_mvn clean package
  mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)
}

createStartScript() {
  if [ ! -d target/dependency ]; then
    error "Application must be packaged first"
    exit 1
  fi
  echo '#!/bin/sh' > target/start.sh
  echo 'exec java $JVM_ARGS -cp /app:/app/lib/* -Djava.security.egd=file:/dev/./urandom \' >> target/start.sh
  cat target/dependency/META-INF/MANIFEST.MF | grep 'Start-Class: ' | cut -d' ' -f2 | tr -d '\r\n' >> target/start.sh
  echo "" >> target/start.sh
  cat target/start.sh
  chmod +x target/start.sh
}

debug() {
  note "Build and debug project in the foreground"
  exec_run_mvn -Dmaven.test.skip=true \
    -Dspring-boot.run.jvmArguments='-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005' \
    spring-boot:run
}

run() {
  note "Build and run project in the foreground"
  exec_run_mvn -Dmaven.test.skip=true \
    clean spring-boot:run
}

test() {
  note "Test project in the foreground"
  exec_run_mvn package test
}

#set the action, default to fail text if none passed.
ACTION=
if [ $# -ge 1 ]; then
  ACTION=$1
  shift
fi

case "${ACTION}" in
  recompile)
    export APPSODY_DEV_MODE=run
    recompile
  ;;
  package)
    common
    package
  ;;
  createStartScript)
    createStartScript
  ;;
  debug)
    common
    export APPSODY_DEV_MODE=debug
    debug
  ;;
  run)
    common
    export APPSODY_DEV_MODE=run
    run
  ;;
  test)
    common
    export APPSODY_DEV_MODE=test
    test
  ;;
  *)
    error "Unexpected script usage, expected one of recompile, package, debug, run, test"
  ;;
esac

#!/bin/bash

# Test pom.xml is present and a file.
if [ ! -f ./pom.xml ]; then
  echo "Error: Could not find Maven pom.xml

  * The project directory (containing an .appsody-conf.yaml file) must contain a pom.xml file.
  * On Windows and MacOS, the project directory should also be shared with Docker: 
    - Win: https://docs.docker.com/docker-for-windows/#shared-drives
    - Mac: https://docs.docker.com/docker-for-mac/#file-sharing
  "
  exit 1   
fi

# Get parent pom information (../pom.xml)
args='export PARENT_GROUP_ID=${project.groupId}; export PARENT_ARTIFACT_ID=${project.artifactId}; export PARENT_VERSION=${project.version}
export LIBERTY_GROUP_ID=${liberty.groupId}; export LIBERTY_ARTIFACT_ID=${liberty.artifactId}; export LIBERTY_VERSION=${version.openliberty-runtime}'
eval $(mvn -q -Dexec.executable=echo -Dexec.args="${args}" --non-recursive -f ../pom.xml exec:exec 2>/dev/null)

# Install parent pom
echo "Installing parent ${PARENT_GROUP_ID}:${PARENT_ARTIFACT_ID}:${PARENT_VERSION}"
mvn install -Dmaven.repo.local=/mvn/repository -Denforcer.skip=true -f ../pom.xml

# Get parent pom information
a_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:groupId" /project/pom.xml)
a_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:artifactId" /project/pom.xml)
a_version=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" /project/pom.xml)
p_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:groupId" pom.xml)
p_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:artifactId" pom.xml)
p_version_range=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:version" pom.xml)

# Check child pom for required parent project
if [ "${p_groupId}" != "${a_groupId}" ] || [ "${p_artifactId}" != "${a_artifactId}" ]; then
  echo "Project pom.xml is missing the required parent:

  <parent>
    <groupId>${a_groupId}</groupId>
    <artifactId>${a_artifactId}</artifactId>
    <version>${a_range}</version>
    <relativePath/>
  </parent>
  "
  exit 1
fi

# Check parent version
if ! /project/util/check_version contains "$p_version_range" "$a_version";  then
  echo "Version mismatch

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

# Check child pom for required liberty version, groupID and artifactId
l_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:assemblyArtifact/x:groupId" pom.xml)
l_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:assemblyArtifact/x:artifactId" pom.xml)
l_version=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:assemblyArtifact/x:version" pom.xml)
if ! [[
        ( "${l_groupId}" == "${LIBERTY_GROUP_ID}" && "${l_artifactId}" == "${LIBERTY_ARTIFACT_ID}" && "${l_version}" == "${LIBERTY_VERSION}"  )
        ||
        ( "${l_groupId}" == "\${liberty.groupId}" && "${l_artifactId}" == "\${liberty.artifactId}" && "${l_version}" == "\${version.openliberty-runtime}" )
     ]]
then
  echo "Project is not using the right OpenLiberty assembly artifact:
  <assemblyArtifact>
    <groupId>${LIBERTY_GROUP_ID}</groupId>
    <artifactId>${LIBERTY_ARTIFACT_ID}</artifactId>
    <version>${LIBERTY_VERSION}</version>
  </assemblyArtifact>

Alternatively you could also use these properties:
  <assemblyArtifact>
    <groupId>\${liberty.groupId}</groupId>
    <artifactId>\${liberty.artifactId}</artifactId>
    <version>\${version.openliberty-runtime}</version>
  <assemblyArtifact>"
  exit 1
fi

# Enforcing loose application
l_looseConfig=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:looseApplication" pom.xml)
if ! [ "${l_looseConfig}" == "true" ]; then
  echo "Should be a loose application:
  <configuration>
    <looseApplication>true</looseApplication>
  </configuration>"
  exit 1
fi
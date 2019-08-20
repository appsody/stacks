#!/bin/bash
# Get parent pom information (../pom.xml)
args='export PARENT_GROUP_ID=${project.groupId}; export PARENT_ARTIFACT_ID=${project.artifactId}; export PARENT_VERSION=${project.version}
export LIBERTY_GROUP_ID=${liberty.groupId}; export LIBERTY_ARTIFACT_ID=${liberty.artifactId}; export LIBERTY_VERSION=${version.openliberty-runtime}'
eval $(mvn -q -Dexec.executable=echo -Dexec.args="${args}" --non-recursive -f ../pom.xml exec:exec 2>/dev/null)

# Install parent pom
echo "Installing parent ${PARENT_GROUP_ID}:${PARENT_ARTIFACT_ID}:${PARENT_VERSION}"
mvn install -Dmaven.repo.local=/mvn/repository -Denforcer.skip=true -f ../pom.xml

# Check child pom for required parent project
if ! grep -Gz "<parent>.*<groupId>${PARENT_GROUP_ID}</groupId>.*</parent>" pom.xml | grep -Gz "<parent>.*<artifactId>${PARENT_ARTIFACT_ID}</artifactId>.*</parent>" | grep -Gzq "<parent>.*<version>${PARENT_VERSION}</version>.*</parent>"
then
  echo "Project is missing required parent:
  <parent>
    <groupId>${PARENT_GROUP_ID}</groupId>
    <artifactId>${PARENT_ARTIFACT_ID}</artifactId>
    <version>${PARENT_VERSION}</version>
  </parent>"
  exit 1
fi

# Check child pom for required liberty version, groupID and artifactId
if ! grep -Gz "<plugin>.*<artifactId>liberty-maven-plugin</artifactId>.*<groupId>${LIBERTY_GROUP_ID}</groupId>\|<groupId>\${liberty.groupId}</groupId>.*</plugin>" pom.xml | grep -Gz "<plugin>.*<artifactId>liberty-maven-plugin</artifactId>.*<artifactId>${LIBERTY_ARTIFACT_ID}</artifactId>\|<artifactId>\${liberty.artifactId}</artifactId>.*</plugin>" | grep -Gzq "<plugin>.*<artifactId>liberty-maven-plugin</artifactId>.*<version>${LIBERTY_VERSION}</version>\|<version>\${version.openliberty-runtime}</version>.*</plugin>"
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
if ! grep -Gzq "<configuration.*<looseApplication>true</looseApplication>.*</configuration" pom.xml
then
  echo "Should be a loose application:
  <configuration>
    <looseApplication>true</looseApplication>
  </configuration>"
  exit 1
fi

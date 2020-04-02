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

# 
# During `appsody build`, we just want to use the same ~/.m2/repository with these mvn
# commands that we use otherwise, so as to avoid extra downloads.  It's only during local dev
# mode that we want to use /mvn/repository, mounted to the host ~/.m2/repository.
#

M2_LOCAL_REPO=

if [ $# -eq 0 ]; then
  echo "ERROR: no argument supplied to script"
  exit 1
fi

if [ "$1" == "dev" ]; then
    M2_LOCAL_REPO="-Dmaven.repo.local=/mvn/repository"
fi

# Get parent pom information
a_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:groupId" /project/pom.xml)
a_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:artifactId" /project/pom.xml)
a_version=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" /project/pom.xml)
p_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:groupId" pom.xml)
p_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:artifactId" pom.xml)
p_version_range=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:parent/x:version" pom.xml)

# Install parent pom
echo "Installing parent ${a_groupId}:${a_artifactId}:${a_version}"
mvn install $M2_LOCAL_REPO -Denforcer.skip=true -f ../pom.xml



# Check child pom for required parent project
if [ "${p_groupId}" != "${a_groupId}" ] || [ "${p_artifactId}" != "${a_artifactId}" ]; then
  echo "STACK VALIDATION ERROR: Project pom.xml is missing the required parent:

  <parent>
    <groupId>${a_groupId}</groupId>
    <artifactId>${a_artifactId}</artifactId>
    ...
  </parent>
  "
  exit 1
fi

# Check parent version
if ! /project/util/check_version contains "$p_version_range" "$a_version";  then
  echo "STACK VALIDATION ERROR: Version mismatch

The version of the appsody stack '${a_version}' does not match the
parent version specified in pom.xml '${p_version_range}'. Please update
the parent version in pom.xml, and test your changes.

  "
  exit 1
fi


# Check that the child pom has not overridden the Open Liberty version

# This is far from the only way from configuring an Open Liberty installation.  The idea is to stop a naive copy/paste/tweak user, not to stop a user determined to override and willing to read the doc.
child_ol_version_property=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:properties/x:version.openliberty-runtime" pom.xml)
child_ol_groupId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:runtimeArtifact/x:groupId" pom.xml)
child_ol_artifactId=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:runtimeArtifact/x:artifactId" pom.xml)
child_ol_version=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:build/x:plugins/x:plugin[x:artifactId='liberty-maven-plugin']/x:configuration/x:runtimeArtifact/x:version" pom.xml)

if ! [[
        ( "${child_ol_groupId}" == "")
        &&
        ( "${child_ol_artifactId}" == "")
        &&
        ( "${child_ol_version}" == "")
        &&
        ("${child_ol_version_property}" == "")
     ]]
then
  echo "STACK VALIDATION ERROR: The project is not using the Open Liberty runtime definition of the parent.
  "
  exit 1
fi

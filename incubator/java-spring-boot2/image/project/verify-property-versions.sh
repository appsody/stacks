#!/bin/bash

# Where is the parent pom located?
PARENT_POM=/project/{{.stack.parentpomfilename}}

# Read the Spring boot version from our parent pom
SPRING_BOOT_VERSION=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:properties/x:spring-boot.version" $PARENT_POM)
# Obtain matching spring-boot-dependencies pom
curl -s "https://raw.githubusercontent.com/spring-projects/spring-boot/v${SPRING_BOOT_VERSION}/spring-boot-project/spring-boot-dependencies/pom.xml" -o /tmp/springdeps.xml

# Collect all property elements from spring pom and our pom
xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -m "/x:project/x:properties/child::node()" -v "name()" -n /tmp/springdeps.xml > /tmp/springprops
xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -m "/x:project/x:properties/child::node()" -v "name()" -n $PARENT_POM > /tmp/parentprops

# Remember the intersection of the property element names
grep -Fxf /tmp/springprops /tmp/parentprops > /tmp/matchingprops

RC=0
# Compare the value of intersected property names, report mismatches.
for prop in $(cat /tmp/matchingprops); do
  echo -n "Evaluating $prop "
  PARENTVER=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:properties/x:$prop" $PARENT_POM)
  SPRINGVER=$(xmlstarlet sel -T -N x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:properties/x:$prop" /tmp/springdeps.xml)
  if [ "$PARENTVER" != "$SPRINGVER" ]; then
    echo ".. Mismatch !!  Spring: $SPRINGVER Parent: $PARENTVER"
    RC=1
  else
    echo ".. OK( $PARENTVER )"
  fi
done

# Report Pass/Fail for log
if [ "$RC" == "1" ]; then
  echo "FAIL: Properties used to control dependency/plugin versions are not in agreement between this stack and the corresponding spring-boot-dependencies artifact."
  echo "      This must be corrected before the stack may be released"
else
  echo "PASS."
fi

# Clean up all temp files.
rm /tmp/matchingprops /tmp/springprops /tmp/parentprops /tmp/springdeps.xml

# convey success/failure via return code.
exit $RC

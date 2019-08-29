if not exist %SystemDrive%%HOMEPATH%\.m2\repository\ (
  mkdir %SystemDrive%%HOMEPATH%\.m2\repository
)
mvnw install -q -f /project/appsody-boot2-pom.xml

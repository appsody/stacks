wget -nv https://repo1.maven.org/maven2/org/osgi/org.osgi.core/6.0.0/org.osgi.core-6.0.0.jar
javac -cp .:org.osgi.core-6.0.0.jar incubator/java-openliberty/image/project/util/RangeIncludesVersion.java
rm -rf experimental
cd incubator
rm -rf java-microprofile
rm -rf java-spring-boot2
rm -rf kitura
rm -rf node-red
rm -rf nodejs-express
rm -rf nodejs-loopback
rm -rf nodejs
rm -rf python-flask
rm -rf quarkus
rm -rf starter
rm -rf swift

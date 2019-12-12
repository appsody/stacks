# Step 1: Build the user's application
FROM adoptopenjdk/openjdk8-openj9

RUN apt-get update && \
    apt-get install -y maven unzip wget xmlstarlet

# Copy and build the dev.appsody:java-openliberty parent pom
COPY ./pom.xml /project/pom.xml
RUN cd /project && mvn -B install dependency:go-offline -DskipTests

# Copy and run a simple version check
COPY ./util /project/util
RUN  /project/util/check_version build

# Copy the user's application pom and resolve all dependencies
COPY ./user-app/pom.xml /project/user-app/pom.xml
COPY ./validate.sh /project/user-app/validate.sh
RUN cd /project/user-app && ./validate.sh  && mvn package -Dskip=true -DskipTests 

# Download Open Liberty here to prevent redownloading each time the app is changed
RUN cd /project/user-app && mvn liberty:install-server

# Copy and build the application source
COPY ./user-app/src /project/user-app/src
RUN cd /project/user-app && mvn package -DskipTests

RUN cd /project/user-app/target/liberty/wlp/usr/servers && \
    mkdir /config && \
    mv defaultServer/* /config/

# Step 2: Package Open Liberty image
FROM open-liberty:kernel-java8-openj9

COPY --chown=1001:0 --from=0 /config/ /config/

EXPOSE 9080
EXPOSE 9443

# Step 1: Build the user's application
FROM kabanero/ubi8-maven:0.9.0 as compile

RUN  groupadd java_group \
  && useradd --gid java_group --shell /bin/bash --create-home java_user \
  && mkdir -p /mvn/repository \
  && chown -R java_user:java_group /mvn \
  && mkdir -p /config \
  && chown -R java_user:java_group /config

USER java_user

# Copy and build the dev.appsody:java-microprofile parent pom
COPY --chown=java_user:java_group ./pom.xml /project/pom.xml
RUN cd /project && mvn -B install dependency:go-offline -DskipTests

# Copy and run a simple version check
COPY --chown=java_user:java_group ./util /project/util
RUN  /project/util/check_version build

# Copy the user's application pom and resolve all dependencies
COPY --chown=java_user:java_group ./user-app/pom.xml /project/user-app/pom.xml
RUN cd /project/user-app && mvn -B package -Dskip=true -DskipTests

# Download Open Liberty here to prevent redownloading each time the app is changed
RUN cd /project/user-app && mvn -B liberty:install-server

# Copy and build the application source. 
# Remove quick-start-security.xml since it is only needed during local development.
COPY --chown=java_user:java_group ./user-app/src /project/user-app/src
RUN cd /project/user-app && \
    echo "QUICK START SECURITY IS NOT SECURE FOR PRODUCTION ENVIRONMENTS. IT IS BEING REMOVED" \
    rm -f src/main/liberty/config/configDropins/defaults/quick-start-security.xml && \
    mvn -B package -DskipTests

RUN cd /project/user-app/target && \
    unzip *.zip && \
    mv wlp/usr/servers/*/* /config/

# Step 2: Package Open Liberty image
FROM openliberty/open-liberty:{{.stack.libertyversion}}-kernel-java8-openj9-ubi

COPY --chown=1001:0 --from=compile /config/ /config/

RUN configure.sh && \
    chmod 664 /opt/ol/wlp/usr/servers/defaultServer/configDropins/defaults/keystore.xml 

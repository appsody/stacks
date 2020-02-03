# Step 1: Build the user's application
FROM adoptopenjdk/openjdk8-openj9

RUN apt-get update && \
    apt-get install -y maven unzip wget xmlstarlet

# Copy and build the dev.appsody:java-openliberty parent pom
COPY ./pom.xml /project/pom.xml
RUN cd /project && mvn -B install dependency:go-offline -DskipTests

# Prime image
#   a) Prime .m2/repository with common artifacts 
#   b) Create target/liberty/wlp/usr/servers/defaultServer dir
COPY ./preload-m2-pom.xml /project/user-app/preload-m2-pom.xml
RUN cd /project/user-app && \ 
    mvn -B -f /project/user-app/preload-m2-pom.xml liberty:install-server dependency:go-offline && \
    rm /project/user-app/preload-m2-pom.xml

# Copy and run a simple version check
COPY ./util /project/util
RUN  /project/util/check_version build

# Copy the validate.sh script and application pom.xml
COPY ./validate.sh /project/user-app/validate.sh
# -- This is the first app-specific piece --
COPY ./user-app/pom.xml /project/user-app/pom.xml
# Validate 
RUN cd /project/user-app && ./validate.sh

# Copy the rest of the application source
COPY ./user-app/src /project/user-app/src

# Build (and run unit tests) 
#  also liberty:create copies config from src->target
RUN cd /project/user-app && \
    mvn -B liberty:create package

RUN cd /project/user-app/target/liberty/wlp/usr/servers && \
    mkdir /config && \
    mv defaultServer/* /config/

# Step 2: Package Open Liberty image
FROM open-liberty:kernel-java8-openj9

COPY --chown=1001:0 --from=0 /config/ /config/
COPY --chown=1001:0 --from=0 /project/user-app/target/*.war /config/apps

RUN configure.sh

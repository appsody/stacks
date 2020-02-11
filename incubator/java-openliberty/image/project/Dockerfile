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
RUN	 /project/util/check_version build

# Copy the validate.sh script and application pom.xml
COPY ./validate.sh /project/user-app/validate.sh
# -- This is the first app-specific piece --
COPY ./user-app/pom.xml /project/user-app/pom.xml
# Validate 
RUN cd /project/user-app && ./validate.sh build

# Copy the rest of the application source
COPY ./user-app /project/user-app

# Build (and run unit tests) 
#  also liberty:create copies config from src->target
RUN cd /project/user-app && \
    mvn -Pappsody-build -B liberty:create package

# process any resources or shared libraries - if they are present in the dependencies block for this project (there may be none potentially)
# test to see if each is present and move to a well known location for later processing in the next stage
RUN cd /project/user-app/target/liberty/wlp/usr/servers && \
	# make a well known place for shared library jars seperate from the rest of the defaultServer contents (to help with caching)
	mkdir /configlibdir && \
	if [ -d ./defaultServer/lib ]; then mv ./defaultServer/lib /configlibdir; fi && \
	mkdir /config && \
	mv -f defaultServer/* /config/ && \
	mkdir /shared && \
	if [ -d ../shared ]; then mv ../shared/* /shared/; fi

# Step 2: Package Open Liberty image
FROM open-liberty:{{.stack.libertyversion}}-kernel-java8-openj9

#2a) copy any resources 
COPY --chown=1001:1001 --from=0 /shared /opt/ol/wlp/usr/shared/

# 2b) next copy shared library
#	  but can't assume config/lib exists - copy from previous stage to a tmp holding place and test
COPY --chown=1001:0 --from=0 /configlibdir/ /tmp/cfglib
RUN if [ "$(ls -A /tmp/cfglib/lib)" ]; then cp -R /tmp/cfglib/lib /config && chmod -R 777 /tmp/cfglib && rm -rf /tmp/cfglib; fi

# 2c) Server config, bootstrap.properties, and everything else
COPY --chown=1001:1001 --from=0 /config/ /config/


# 2d) Changes to the application binary
COPY --chown=1001:0 --from=0 /project/user-app/target/* /tmp/wars/
RUN if [ -e /tmp/wars/*.war ]; then cp /tmp/wars/*.war /config/apps; fi && if [ -e /tmp/wars/*.ear ]; then cp /tmp/wars/*.ear /config/apps; fi && chmod -R 777 /tmp/wars && rm -rf /tmp/wars

RUN configure.sh

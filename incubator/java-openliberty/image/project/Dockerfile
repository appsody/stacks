# Step 1: Build the user's application
FROM kabanero/ubi8-maven:0.3.1 as compile

RUN  groupadd java_group \
   && useradd --gid java_group --shell /bin/bash --create-home java_user \
   && mkdir -p /mvn/repository \
   && chown -R java_user:java_group /mvn \
   && mkdir -p /config \
   && chown -R java_user:java_group /config \
# make a well known place for shared library jars seperate from the rest of the defaultServer contents (to help with caching)
   && mkdir /configlibdir \
   && chown -R java_user:java_group /configlibdir \
   &&  mkdir /shared \
   && chown -R java_user:java_group /shared 

 USER java_user

# Copy and build the dev.appsody:java-openliberty parent pom
COPY --chown=java_user:java_group ./pom.xml /project/pom.xml
RUN cd /project && mvn -B install dependency:go-offline -DskipTests

# Prime image
#   a) Prime .m2/repository with common artifacts 
#   b) Create target/liberty/wlp/usr/servers/defaultServer dir
COPY --chown=java_user:java_group ./preload-m2-pom.xml /project/user-app/preload-m2-pom.xml
RUN cd /project/user-app && \ 
    mvn -B -f /project/user-app/preload-m2-pom.xml liberty:install-server dependency:go-offline && \
    rm /project/user-app/preload-m2-pom.xml

# Copy and run a simple version check
COPY --chown=java_user:java_group ./util /project/util
RUN	 /project/util/check_version build

# Copy the validate.sh script and application pom.xml
COPY --chown=java_user:java_group ./validate.sh /project/user-app/validate.sh
# -- This is the first app-specific piece --
COPY --chown=java_user:java_group ./user-app/pom.xml /project/user-app/pom.xml
# Validate 
RUN cd /project/user-app && ./validate.sh build

# Copy the rest of the application source
COPY --chown=java_user:java_group ./user-app /project/user-app

# Build (and run unit tests) 
#  also liberty:create copies config from src->target
RUN cd /project/user-app && \
    mvn -Pappsody-build -B liberty:create package

# process any resources or shared libraries - if they are present in the dependencies block for this project (there may be none potentially)
# test to see if each is present and move to a well known location for later processing in the next stage
# 
# Also remove quick-start-security.xml since it's convenient for local dev mode but should not be in the production image.
RUN cd /project/user-app/target/liberty/wlp/usr/servers && \
	if [ -d ./defaultServer/lib ]; then mv ./defaultServer/lib /configlibdir; fi && \
	if [ ! -d /configlibdir/lib ]; then mkdir /configlibdir/lib; fi && \
	rm -f defaultServer/configDropins/defaults/quick-start-security.xml && \
	mv -f defaultServer/* /config/ && \

	if [ -d ../shared ]; then mv ../shared/* /shared/; fi

# Step 2: Package Open Liberty image
FROM openliberty/open-liberty:{{.stack.libertyversion}}-kernel-java8-openj9-ubi

#2a) copy any resources 
COPY --chown=1001:0 --from=compile /shared /opt/ol/wlp/usr/shared/

# 2b) next copy shared library
#	  but can't assume config/lib exists - copy from previous stage to a tmp holding place and test
COPY --chown=1001:0 --from=compile /configlibdir/ /config

# 2c) Server config, bootstrap.properties, and everything else
COPY --chown=1001:0 --from=compile /config/ /config/


# 2d) Changes to the application binary
COPY --chown=1001:0 --from=compile /project/user-app/target/* /tmp/wars/
RUN if [ -e /tmp/wars/*.war ]; then cp /tmp/wars/*.war /config/apps; fi && if [ -e /tmp/wars/*.ear ]; then cp /tmp/wars/*.ear /config/apps; fi && chmod -R 777 /tmp/wars && rm -rf /tmp/wars

RUN configure.sh

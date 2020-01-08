FROM {{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}} as compile

COPY . /project

WORKDIR /project/user-app

# Ensure parent pom is used for compile
RUN cd /project && mvn -B install dependency:go-offline -DskipTests

# Build version range check util for project/parent pom
RUN  /project/util/check_version build

# Build project
RUN ../validate.sh && mvn -B install -DskipTests

# Gather built resources to staging dirs
RUN cd target && \
    unzip *.zip && \
    mkdir -p /config && \
    mv wlp/usr/servers/*/* /config/ && \
    mv wlp/usr/shared/resources/lib.index.cache /lib.index.cache

FROM open-liberty:kernel-java8-openj9

# Ensure up to date / patched OS
USER root
RUN  apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*
USER 1001

# Bring in built artifacts from previous stage
COPY --chown=1001:0 --from=compile /config/ /config/
COPY --chown=1001:0 --from=compile /lib.index.cache/ /lib.index.cache/

# Set metadata
ARG artifactId=appsody-spring-liberty
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.title="${artifactId}"
LABEL appsody.stack="{{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}}.{{.stack.semver.patch}}"

EXPOSE 9080
EXPOSE 9443

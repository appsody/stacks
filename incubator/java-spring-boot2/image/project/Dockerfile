FROM {{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}} as compile

#setup project folder for java build step
COPY . /project

WORKDIR /project/user-app

RUN /project/util/check_version build \
 && /project/java-spring-boot2-build.sh package

####
FROM adoptopenjdk:8-jdk-openj9

# Ensure up to date / patched OS
RUN  apt-get -qq update \
  && apt-get -qq install -y curl wget xmlstarlet unzip \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.title="${artifactId}"
LABEL appsody.stack={{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}}.{{.stack.semver.patch}}

COPY --from=compile /project/user-app/target/app.jar /app.jar

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "sh", "-c", "exec java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

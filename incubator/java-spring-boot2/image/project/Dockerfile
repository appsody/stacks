FROM kabanero/ubi8-maven:0.3.0 as compile

RUN  groupadd --gid 1000 java_group \
  && useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user \
  && mkdir -p /mvn/repository \
  && chown -R java_user:java_group /mvn

#setup project folder for java build step
USER java_user

# Layer caching for stack dependencies
LABEL appsody.stack={{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}}.{{.stack.semver.patch}}
COPY --chown=java_user:java_group appsody-boot2-pom.xml /mvn/appsody-boot2-pom.xml
RUN mvn --no-transfer-progress -B dependency:go-offline install -f /mvn/appsody-boot2-pom.xml

# Layer caching for application dependencies
COPY --chown=java_user:java_group user-app/pom.xml /mvn/pom.xml
RUN mvn --no-transfer-progress -B dependency:go-offline -f /mvn/pom.xml

# Copy and build project
COPY --chown=java_user:java_group . /project

WORKDIR /project/user-app

RUN /project/util/check_version build \
 && /project/java-spring-boot2-build.sh package \
 && /project/java-spring-boot2-build.sh createStartScript

### Base image for app.

### Red Hat Runtime image based on RHEL. Requires subscription.
## Requires Auth
## FROM registry.redhat.io/redhat-openjdk-18/openjdk18-openshift:1.7
## Unauthed as per https://access.redhat.com/containers/?tab=images&get-method=unauthenticated#/registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
#FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.7

FROM kabanero/ubi8-openjdk:0.3.0

RUN groupadd --gid 1000 java_group \
 && useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.title="${artifactId}"
LABEL appsody.stack={{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}}.{{.stack.semver.patch}}

COPY --chown=java_user:java_group --from=compile /project/user-app/target/start.sh /start.sh

ARG DEPENDENCY=/project/user-app/target/dependency
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/META-INF /app/META-INF
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/BOOT-INF/classes /app

USER java_user

EXPOSE 8080
EXPOSE 8443
ENTRYPOINT [ "/start.sh" ]

FROM kabanero/ubi8-maven:0.3.0 as compile

USER root

COPY . /project

WORKDIR /project/user-app

RUN mkdir -p /mvn/repository \
 && /project/util/check_version build \
 && /project/java-spring-boot2-build.sh package

USER java_user

### Base image for app.

### Red Hat Runtime image based on RHEL. Requires subscription.
## Requires Auth
## FROM registry.redhat.io/redhat-openjdk-18/openjdk18-openshift:1.7
## Unauthed as per https://access.redhat.com/containers/?tab=images&get-method=unauthenticated#/registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
#FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.7

FROM kabanero/ubi8-openjdk:0.3.0

ENV JVM_ARGS=""

RUN groupadd --gid 1000 java_group \
  && useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user

COPY --from=compile /project/user-app/target/app.jar /app.jar

USER java_user

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "sh", "-c", "exec java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

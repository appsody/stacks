FROM kabanero/ubi8-maven:0.3.0 as compile

USER root

COPY . /project

WORKDIR /project/user-app

RUN mkdir -p /mvn/repository \
 && /project/util/check_version build \
 && /project/java-spring-boot2-build.sh package

### Base image for app.

### RHR
## Requires Auth
## FROM registry.redhat.io/redhat-openjdk-18/openjdk18-openshift
## Unauthed as per https://access.redhat.com/containers/?tab=images&get-method=unauthenticated#/registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift

ENV JVM_ARGS=""

COPY --from=compile /project/user-app/target/app.jar /app.jar

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "sh", "-c", "exec java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

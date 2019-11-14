FROM {{APPSODY_STACK}} as compile

#setup project folder for java build step
COPY . /project

WORKDIR /project/user-app

USER root

RUN /project/util/check_version build \
 && /project/java-spring-boot2-build.sh package

USER java_user

####
FROM kabanero/ubi8-openjdk:0.3.0

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL maintainer="IBM Java Engineering at IBM Cloud"
LABEL org.opencontainers.image.version=${version}
LABEL org.opencontainers.image.title=${artifactId}
LABEL appsody.stack="kabanero/java-spring-boot2:0.3.13"

COPY --from=compile /project/user-app/target/app.jar /app.jar

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "sh", "-c", "exec java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

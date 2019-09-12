FROM {{APPSODY_STACK}} as compile

#setup project folder for java build step
COPY . /project

RUN mkdir -p /mvn/repository \
 && /project/util/check_version build

WORKDIR /project/user-app

RUN /project/java-spring-boot2-build.sh package

####
FROM adoptopenjdk:8-jdk-openj9

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.title="${artifactId}"
LABEL appsody.stack="{{APPSODY_STACK_FULL}}"

COPY --from=compile /project/user-app/target/app.jar /app.jar

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "sh", "-c", "exec java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

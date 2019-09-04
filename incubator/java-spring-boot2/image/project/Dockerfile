FROM {{APPSODY_STACK}} as compile

#setup project folder for java build step
COPY . /project

WORKDIR /project/user-app

RUN mkdir -p /mvn/repository \
 && /project/java-spring-boot2-build.sh package

####
FROM adoptopenjdk:8-jdk-openj9

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version=${version}
LABEL org.opencontainers.image.title=${artifactId}

COPY --from=compile /project/user-app/target/app.jar /app.jar

ENTRYPOINT [ "sh", "-c", "java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

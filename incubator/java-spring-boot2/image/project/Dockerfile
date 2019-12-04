FROM {{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}} as compile

#setup project folder for java build step
COPY . /project

USER root
RUN chown -R java_user:java_group /project
USER java_user

WORKDIR /project/user-app

RUN /project/util/check_version build \
 && /project/java-spring-boot2-build.sh package

#Build start.sh
RUN echo '#!/bin/sh' > /project/user-app/target/start.sh \
 && cat /project/user-app/target/mainclass | sed -e 's#\(.*\)#sh -c "exec java $JVM_ARGS -cp /app:/app/lib/* -Djava.security.egd=file:/dev/./urandom \1"#' >> /project/user-app/target/start.sh \
 && chmod +x /project/user-app/target/start.sh \
 && chown -R 1000:1000 /project/user-app/target/dependency

####
FROM adoptopenjdk:8-jdk-openj9

# Ensure up to date / patched OS
RUN  apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.title="${artifactId}"
LABEL appsody.stack={{.stack.image.namespace}}/{{.stack.id}}:{{.stack.semver.major}}.{{.stack.semver.minor}}.{{.stack.semver.patch}}

USER root
RUN groupadd --gid 1000 java_group \
 && useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user
ARG DEPENDENCY=/project/user-app/target/dependency
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/META-INF /app/META-INF
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/BOOT-INF/classes /app
COPY --chown=java_user:java_group --from=compile /project/user-app/target/start.sh /start.sh

USER java_user
EXPOSE 8080
EXPOSE 8443
ENTRYPOINT [ "/start.sh" ]

FROM {{.stack.baseimage}} as compile

# Ensure up to date / patched OS
RUN  apt-get -qq update \
  && apt-get -qq install -y curl wget xmlstarlet unzip \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*

RUN  groupadd --gid 1000 java_group \
  && useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user \
  && mkdir -p /mvn/repository \
  && chown -R java_user:java_group /mvn

#setup project folder for java build step
USER java_user

# Layer caching for stack dependencies
LABEL "stack.appsody.dev/id"="{{.stack.image.namespace}}/{{.stack.id}}"
LABEL "stack.appsody.dev/version"="{{.stack.semver.major}}.{{.stack.semver.minor}}.{{.stack.semver.patch}}"
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

####
FROM adoptopenjdk:8-jdk-openj9

# Ensure up to date / patched OS
RUN  apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*

RUN groupadd --gid 1000 java_group \
 && useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.title="${artifactId}"

COPY --chown=java_user:java_group --from=compile /project/user-app/target/start.sh /start.sh

ARG DEPENDENCY=/project/user-app/target/dependency
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/META-INF /app/META-INF
COPY --chown=java_user:java_group --from=compile ${DEPENDENCY}/BOOT-INF/classes /app

USER java_user

EXPOSE 8080
EXPOSE 8443
ENTRYPOINT [ "/start.sh" ]

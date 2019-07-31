FROM maven:3.6-ibmjava-8 as compile
LABEL maintainer="IBM Java Engineering at IBM Cloud"

# Ensure up to date / patched OS
RUN  apt-get -qq update \
  && apt-get -qq install -y curl wget xmlstarlet unzip \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/* \
  && mkdir -p /mvn/repository

# Kotlin support
COPY ./stack.properties /project/stack.properties
RUN cd /usr/lib && \
    KVER=$(cat /project/stack.properties | grep kotlin.version | sed 's/kotlin.version=//') && \
    wget -q https://github.com/JetBrains/kotlin/releases/download/v$KVER/kotlin-compiler-$KVER.zip && \
    unzip kotlin-compiler-*.zip && \
    rm kotlin-compiler-*.zip && \
    rm -f kotlinc/bin/*.bat  

#setup project folder for java build step
COPY . /project
COPY ./.mvn-stack-settings.xml /usr/share/maven/conf/settings.xml

WORKDIR /project/user-app

RUN /project/java-spring-boot2-build.sh package

####
FROM adoptopenjdk:8-jdk-openj9

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL maintainer="IBM Java Engineering at IBM Cloud"
LABEL org.opencontainers.image.version=${version}
LABEL org.opencontainers.image.title=${artifactId}

COPY --from=compile /project/user-app/target/app.jar /app.jar

ENTRYPOINT [ "sh", "-c", "java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

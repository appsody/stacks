FROM registry.access.redhat.com/ubi8/ubi as compile

RUN yum upgrade --disableplugin=subscription-manager -y \
   && yum clean --disableplugin=subscription-manager packages \
   && mkdir -p /mvn/repository \
   && echo 'Finished installing dependencies'

# Dependency install
RUN yum install --disableplugin=subscription-manager -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
   && yum install --disableplugin=subscription-manager -y curl unzip xmlstarlet

# java8 install
RUN yum install --disableplugin=subscription-manager -y wget ca-certificates
ENV JAVA_VERSION 1.8.0_sr5fp37

RUN set -eux; \
   ESUM='51f6600dcc51c238bd4fbed73521e225094d7afa9afa2c8fb35ea78519a71930'; \
   YML_FILE='sdk/linux/x86_64/index.yml'; \
   BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \
   wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml ${BASE_URL}/${YML_FILE}; \
   JAVA_URL=$(sed -n '/^'${JAVA_VERSION}:'/{n;s/\s*uri:\s//p}'< /tmp/index.yml); \
   wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.bin ${JAVA_URL}; \
   echo "${ESUM}  /tmp/ibm-java.bin" | sha256sum -c -; \
   echo "INSTALLER_UI=silent" > /tmp/response.properties; \
   echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties; \
   echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties; \
   mkdir -p /opt/ibm; \
   chmod +x /tmp/ibm-java.bin; \
   /tmp/ibm-java.bin -i silent -f /tmp/response.properties; \
   rm -f /tmp/response.properties; \
   rm -f /tmp/index.yml; \
   rm -f /tmp/ibm-java.bin;

ENV JAVA_HOME=/opt/ibm/java/jre \
PATH=/opt/ibm/java/bin:$PATH \
IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"

# Maven install
ARG MAVEN_VERSION=3.6.2
ARG USER_HOME_DIR="/root"
ARG SHA=d941423d115cd021514bfd06c453658b1b3e39e6240969caf4315ab7119a77299713f14b620fb2571a264f8dff2473d8af3cb47b05acf0036fc2553199a5c1ee
ARG BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
 && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
 && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
 && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
 && rm -f /tmp/apache-maven.tar.gz \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

#setup project folder for java build step
COPY . /project
COPY ./mvn-stack-settings.xml /usr/share/maven/conf/settings.xml

# OSGI core for version range processing
RUN  /project/util/check_version build

WORKDIR /project/user-app

RUN /project/java-spring-boot2-build.sh package

####
FROM registry.access.redhat.com/ubi8/ubi

ARG artifactId=appsody-spring
ARG version=1.0-SNAPSHOT
ENV JVM_ARGS=""

LABEL maintainer="IBM Java Engineering at IBM Cloud"
LABEL org.opencontainers.image.version=${version}
LABEL org.opencontainers.image.title=${artifactId}

#Install openj9 v8

RUN yum upgrade --disableplugin=subscription-manager -y \
   && yum clean --disableplugin=subscription-manager packages

RUN yum install --disableplugin=subscription-manager -y curl ca-certificates

ENV JAVA_VERSION jdk8u222-b10_openj9-0.15.1

RUN set -eux; \
   ESUM='20cff719c6de43f8bb58c7f59e251da7c1fa2207897c9a4768c8c669716dc819'; \
   BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10_openj9-0.15.1/OpenJDK8U-jdk_x64_linux_openj9_8u222b10_openj9-0.15.1.tar.gz'; \
   curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
   echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
   mkdir -p /opt/java/openjdk; \
   cd /opt/java/openjdk; \
   tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
   rm -rf /tmp/openjdk.tar.gz;

   ENV JAVA_HOME=/opt/java/openjdk \
   PATH="/opt/java/openjdk/bin:$PATH"
   ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"

COPY --from=compile /project/user-app/target/app.jar /app.jar

ENTRYPOINT [ "sh", "-c", "java $JVM_ARGS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

FROM adoptopenjdk/openjdk8-openj9

RUN apt-get update && \
    apt-get install -y maven unzip wget

# Kotlin support
COPY ./stack.properties /project/stack.properties
RUN cd /usr/lib && \
    KVER=$(cat /project/stack.properties | grep kotlin.version | sed 's/kotlin.version=//') && \
    wget -q https://github.com/JetBrains/kotlin/releases/download/v$KVER/kotlin-compiler-$KVER.zip && \
    unzip kotlin-compiler-*.zip && \
    rm kotlin-compiler-*.zip && \
    rm -f kotlinc/bin/*.bat  

COPY . /project

WORKDIR /project/user-app

RUN mvn install -DskipTests

RUN cd target && \
    unzip *.zip && \
    mkdir /config && \
    mv wlp/usr/servers/*/* /config/

FROM open-liberty:kernel-java8-openj9

COPY --chown=1001:0 --from=0 /config/ /config/

EXPOSE 9080
EXPOSE 9443
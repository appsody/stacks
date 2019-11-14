FROM adoptopenjdk/openjdk8-openj9

RUN apt-get update && \
    apt-get install -y maven unzip wget xmlstarlet

COPY . /project

RUN  /project/util/check_version build

RUN cd /project && mvn -B install dependency:go-offline -DskipTests

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

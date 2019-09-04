FROM adoptopenjdk/openjdk8-openj9

RUN apt-get update && \
    apt-get install -y maven unzip wget

COPY . /project

WORKDIR /project/user-app

RUN mvn install -DskipTests

RUN cd target && \
    unzip *.zip && \
    mkdir /config && \
    mv wlp/usr/servers/*/* /config/ && \
    mv wlp/usr/shared/resources/lib.index.cache /lib.index.cache

FROM open-liberty:kernel-java8-openj9

COPY --chown=1001:0 --from=0 /config/ /config/
COPY --chown=1001:0 --from=0 /lib.index.cache/ /lib.index.cache/

EXPOSE 9080
EXPOSE 9443
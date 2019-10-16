FROM kabanero/ubi8-maven

USER root

COPY . /project

RUN  /project/util/check_version build

RUN cd /project && mvn -B install dependency:go-offline -DskipTests

WORKDIR /project/user-app

RUN mvn install -DskipTests

RUN cd target && \
    unzip *.zip && \
    mkdir /config && \
    mv wlp/usr/servers/*/* /config/

FROM openliberty/open-liberty:microProfile3-ubi-min

COPY --chown=1001:0 --from=0 /config/ /opt/ol/wlp/usr/servers/defaultServer/

EXPOSE 9080
EXPOSE 9443

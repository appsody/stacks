## Stage 1 : build with maven builder image with native capabilities
FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java11 AS build

COPY . /project
RUN cd /project && mvn -B install dependency:go-offline -DskipTests
# Install user-app dependencies
WORKDIR /project/user-app
COPY ./user-app/src ./src
COPY ./user-app/pom.xml ./
USER root
RUN chown -R quarkus .
USER quarkus
RUN mvn -B -Pnative clean package


## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /work/
COPY --from=build /project/user-app/target/*-runner /work/application

USER root
RUN microdnf -y install shadow-utils \
    && microdnf clean all ;\
    useradd -r -g 0 -s /usr/sbin/nologin quarkus

RUN chown -R quarkus /work
RUN chmod -R g+w /work


USER quarkus
EXPOSE 8080
CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]

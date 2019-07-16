## Stage 1 : build with maven builder image with native capabilities
FROM quay.io/quarkus/centos-quarkus-maven:19.0.2 AS build


# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app/src ./src
COPY ./user-app/pom.xml ./
USER root
RUN chown -R quarkus .
USER quarkus
RUN mvn -Pnative clean package


## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /work/
COPY --from=build /project/user-app/target/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]

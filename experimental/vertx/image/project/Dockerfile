FROM adoptopenjdk/openjdk8-openj9 as build

RUN apt-get update && \
    apt-get install -y maven unzip

COPY . /project

# Install user-app dependencies
WORKDIR /project/user-app
COPY ./user-app/src ./src
COPY ./user-app/pom.xml ./
RUN mvn clean package

FROM vertx/vertx3

WORKDIR /work/
COPY --from=build /project/user-app/target/*.jar /work/

COPY --from=build /project/user-app/pom.xml /work
RUN apt-get install -y xmlstarlet

COPY start.sh .
RUN chmod +x ./start.sh

RUN chmod 775 /work
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "/work/start.sh"]
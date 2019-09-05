FROM openjdk8-openj9-local

RUN apt-get install -y maven unzip

# Pre-cache of maven dependencies
COPY pom.xml /project/ 
COPY user-app/pom.xml /project/user-app/
RUN mvn -B -f /project/pom.xml install dependency:copy-dependencies && \
    mvn -B -f /project/pom.xml dependency:resolve-plugins -DexcludeTransitive=true && \
    mvn -B -f /project/user-app/pom.xml install dependency:copy-dependencies && \
    mvn -B -f /project/user-app/pom.xml dependency:resolve-plugins -DexcludeTransitive=true

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
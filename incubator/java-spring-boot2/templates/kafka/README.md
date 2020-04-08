# Kafka Template

The java-spring-boot2 `kafka` template provides a consistent way of developing Spring Boot applications which connect to Kafka. This template is an extension of `default` template and uses [spring-kafka](https://spring.io/projects/spring-kafka#overview) to connect to the Kafka instance running on Kubernetes managed by [Strimzi](https://strimzi.io/) Kafka operator.

The `kafka` template provides a `pom.xml` file that references the parent POM defined by the stack, dependencies that enables the Spring boot application to connect to Kafka, simple producer that publishes a message to the Kafka topic and a simple consumer that consumes the messages published on to Kafka topic by the producer. It also provides a basic liveness endpoint, and a set of unit tests that ensure enabled actuator endpoints work properly: `/actuator/health`, `/actuator/metric`, `/actuator/prometheus` and `/actuator/liveness`

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

```
mkdir my-project
cd my-project
appsody init java-spring-boot2 kafka
```
This will initialize a Spring Boot 2 project using the kafka template.

2. Once your project has been initialized you can then run your application using the following command:

```
appsody run --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}"
```
E.g:
```
appsody run --network kafka_default --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=kafka:9092"
```
`DOCKER_NETWORK_NAME` is the name of the docker network in which the kafka container is running.

This template expects `KAFKA_BOOTSTRAP_SERVERS` environment variable to be set to addresses of the bootstrap servers of kafka.

This launches a Docker container that will run your application in the foreground, exposing it on port 8080. You should see that the producer publishes message to the kafka topic and the consumer reads it. The application will be restarted automatically when changes are detected.

3. You should be able to access the following endpoints, as they are exposed by your template application by default:

* Health endpoint: http://localhost:8080/actuator/health
* Liveness endpoint: http://localhost:8080/actuator/liveness
* Metrics endpoint: http://localhost:8080/actuator/metrics
* Prometheus endpoint: http://localhost:8080/actuator/prometheus

4. To deploy the application to Kubernetes run the following command:
```
appsody deploy
```
Make sure to add the `KAFKA_BOOTSTRAP_SERVERS` environment variable in the `app-deploy.yaml` before running the above command

```
env:
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: ${KAFKA_BOOTSTRAP_SERVERS}
```

If you are trying to connect to a Kafka instance managed by Strimzi Kafka operator, the value of `KAFKA_BOOTSTRAP_SERVERS` should be a fully qualified service hostname.

E.g: my-cluster-kafka-bootstrap.strimzi.svc.cluster.local:9092

* `my-cluster` is the Kafka resource name.
* `kafka-bootstrap` is the Broker load balancer name.
* `strimzi` is the namespace in which Kafka instance is deployed.
* `9092` is the PLAINTEXT port.

# Kafka Template

The `kafka` template provides you with an Express application and skeleton code
to publish and subscribe to Kafka using
[node-rdkafka](https://www.npmjs.com/package/node-rdkafka).


## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init nodejs-express kafka
    ```

    This will initialize a Node.js Express project using the `kafka` template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}"
    ```

E.g:
```
appsody run --network DOCKER_NETWORK_NAME --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=kafka:9092"
```
`DOCKER_NETWORK_NAME` is the name of the docker network in which the kafka container is running.

This template expects `KAFKA_BOOTSTRAP_SERVERS` environment variable to be set
to addresses of the bootstrap servers of kafka.

1. To deploy the application to Kubernetes run the following command:
    ```bash
    appsody deploy
    ```
    Make sure to add the `KAFKA_BOOTSTRAP_SERVERS` environment variable in the `app-deploy.yaml` before running the above command

    ```yaml
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


## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

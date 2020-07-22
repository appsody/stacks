# Kafka Template

The `kafka` template provides you with an Express application and skeleton code
to publish and subscribe to Kafka using
[node-rdkafka](https://www.npmjs.com/package/node-rdkafka).


### Create an Appsody Project

Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init nodejs-express kafka
    ```
This will initialize a Node.js Express project using the `kafka` template.
    
### Start Kafka and Zookeeper

In order to run the starter app.js you must start Kafka and ZooKeeper containers. ZooKeeper is a dependency of Kafka. Use the docker-compose.yaml that is provided in the template to start both containers.

Start docker compose with the following command:
    
    ```docker-compose up```
    
Run ```docker network list``` to see your new network with the name of your project directory and the word ```_default``` appended. For example, ```my-project_default```. This is your `DOCKER_NETWORK_NAME`.

### Run the Appsody application

After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}"
    ```

    E.g:
    ```
    appsody run --network DOCKER_NETWORK_NAME --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=kafka:9092"
    ```

This template expects `KAFKA_BOOTSTRAP_SERVERS` environment variable to be set to addresses of the bootstrap servers of kafka.

### Produce a message to a Kafka topic

You can either POST to the /produce endpoint. This must be in json format if you are using the starter application, for example:

```curl -d '{"foo":"bar"}' -H 'Content-Type: application/json' http://localhost:<port>/produce```

or you can start a Kafka producer. You will first need to run another container in the same network:

```docker run -it --network my-project_default strimzi/kafka:0.16.0-kafka-2.4.0 /bin/bash```

Now we can produce a message to ```my-topic``` by running:

```bin/kafka-console-producer.sh --broker-list kafka:9092 --topic my-topic```

Type a message in the console. 

### Consume a message from a Kafka topic

Start another container in the same network, as before, for the consumer:

```docker run -it --network my-node-project_default  strimzi/kafka:0.16.0-kafka-2.4.0 /bin/bash```

To consume messages you can run the following command:

```bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic my-topic --from-beginning```

This will start consuming messages from when it is initiated so now you can produce some more messages and you should see them. 

### Deploy to Kubernetes

To deploy the application to Kubernetes run the following command:
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

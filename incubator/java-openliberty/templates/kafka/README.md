# Kafka template for Open Liberty

This template can be used to develop Liberty applications that connect to Kafka by using MicroProfile Reactive messaging. A simple `StarterApplication` is included that enables basic production and consumption of events. 


## Getting Started with the StarterApplication.

### 1. Create a new folder and initialize it using appsody init:


```
mkdir test-appsody-kafka
cd test-appsody-kafka
appsody init java-openliberty kafka
```

### 2. Start Kafka and ZooKeeper

In order to run the `StarterApplication` you must start Kafka and ZooKeeper containers. ZooKeeper is a dependency of Kafka.  Use the `docker-compose.yaml` that is provided in the template to start both containers. 


Start docker compose with the following command:

```docker-compose up```

If you run `docker network list`, you should see a new network with the name of your project directory and the word `_default` appended. For example, `test-appsody-kafka_default`.

Alternatively, if you want to connect to a Kafka broker elsewhere, edit `src/main/resources/META-INF/microprofile-config.properties` and set the value of the `mp.messaging.connector.liberty-kafka.bootstrap.servers` property to the host and port number of the your broker.

### 3. Run the Appsody application in the new network

Your Appsody application must be run in the same network as Kafka.

Run the application using the following command:

```appsody run --network test-appsody-kafka_default```

### 4. Produce a message to a topic

Run another container in the same network:

```docker run -it --network test-appsody-kafka_default strimzi/kafka:0.16.0-kafka-2.4.0 /bin/bash```

The next step is to produce a message. Use the following command to start a Kafka Producer that writes to `incomingTopic1`:

```bin/kafka-console-producer.sh --broker-list kafka:9092 --topic incomingTopic1```

Enter text at the prompt to produce a message.

### 5. Consume a message from a topic

To view the messages, you can either look at the console log from the Appsody application or you can create a Kafka console consumer using the following command:

```bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic incomingTopic1 --from-beginning```

## Deploying to Kubernetes

When deploying to a Kubernetes environment, you must configure your application to connect to the Kafka broker.  You can use the [Strimzi Kafka operator](https://strimzi.io/docs/quickstart/latest/) to deploy a Kafka broker in a Kubernetes cluster. 

To configure the connection, first run the following command:

```appsody build```

This command generates `app-deploy.yaml` file.
Edit the file to override the bootstrap server configuration by setting an enviornment variable as follows:

```
spec:
  env:
    - name: MP_MESSAGING_CONNECTOR_LIBERTY_KAFKA_BOOTSTRAP_SERVERS
      value: <your-kafka-host>:9092
```  

Then run the following command to deploy your application:

```
appsody deploy --no-build
```

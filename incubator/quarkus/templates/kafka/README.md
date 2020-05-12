# Kakfa template for Quarkus

This template provides a Java application which demonstrates using MicroProfile Reactive Messaging to consume and produce messages on Kafka topics. The application uses the example from the [Quarkus Kafka guide](https://quarkus.io/guides/kafka). 

A bean produces a random `Integer` onto a Reactive Messaging channel named "generated-price" every 5 seconds. This channel is connected to a Kafka topic named "prices". Another bean consumes from that topic, applies a conversion, and publishes a `double` onto another channel named "my-data-stream". Finally, that channel is streamed to a JAX-RS endpoint `/prices.html`, using [Server-sent Events](https://en.wikipedia.org/wiki/Server-sent_events).

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

```bash
mkdir my-project
cd my-project
appsody init quarkus kafka
```
This will initialize a Quarkus project using the `kafka` template.

## Running locally

The template provides a sample `docker-compose.yaml` which you can use to run a single-node Kafka cluster on your local machine. To start Kafka locally, run `docker-compose up`. This will start Kafka, Zookeeper, and also create a Docker network on your machine, which you can find the name of by running `docker network list`.

To run the application using Appsody, use this command, substituting in the name of your Docker network:

`$ appsody run --network network_name --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=kafka:9092"`

To shut down Kafka and Zookeeper afterwards, run `docker-compose down`.

## Running on Kubernetes

To run on Kubernetes, you will first need to deploy Kafka. The easiest way to do that is to use the [Strimzi operator quickstart](https://strimzi.io/quickstarts/). This will deploy a basic Kafka cluster into a `kafka` namespace on your Kubernetes cluster.

You will need to inject the address of your Kafka into your Quarkus application via the `KAFKA_BOOTSTRAP_SERVERS` environment variable. To do this, you can add an `env:` section to your `app-deploy.yaml` that is generated when you run `appsody build`.

```yaml
spec:
  env:
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: my-cluster-kafka-bootstrap.default.svc:9092
```

To get the `value` you need, you can run `kubectl describe kafka -n kafka` and examine the listener address in the status section.

Once you have updated your `app-deploy.yaml` to inject the environment variable, you can run `appsody deploy` to run your Quarkus application on Kubernetes.

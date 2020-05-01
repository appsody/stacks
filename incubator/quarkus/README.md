# Quarkus Stack

The Quarkus stack is designed to provide a foundation for building and running Java applications on Quarkus with Appsody.

This stack is based on the `Quarkus 1.3.2.Final` runtime. It allows you to develop new or existing Java applications that run on Quarkus and can be turned into a native executable for a low memory footprint and near instantaneous (< 10ms) start times.

## What is Quarkus?

See: https://quarkus.io/

> Kubernetes Native Java stack tailored for GraalVM & OpenJDK HotSpot, crafted from the best of breed Java libraries and standards

## Templates

Templates are used to create your local project and start your development. This stack provides two templates you can choose from: `default` and `kafka`. If you do not specify a template, the `default` template will be used.

### `default` template

This template provides a simple Java application with a JAX-RS "Hello World!" REST API example and a simple HTML welcome page.

### `kafka` template

This template provides a Java application which demonstrates using MicroProfile Reactive Messaging to consume and produce messages on Kafka topics. The application uses the example from the [Quarkus Kafka guide](https://quarkus.io/guides/kafka).

A bean produces a random `Integer` onto a Reactive Messaging channel named "generated-price" every 5 seconds. This channel is connected to a Kafka topic named "prices". Another bean consumes from that topic, applies a conversion, and publishes a `double` onto another channel named "my-data-stream". Finally, that channel is streamed to a JAX-RS endpoint `/prices.html`, using [Server-sent Events](https://en.wikipedia.org/wiki/Server-sent_events).

#### Running locally

The template provides a sample `docker-compose.yaml` which you can use to run a single-node Kafka cluster on your local machine. To start Kafka locally, run `docker-compose up`. This will start Kafka, Zookeeper, and also create a Docker network on your machine, which you can find the name of by running `docker network list`.

To run the application using Appsody, use this command, substituting in the name of your Docker network:

`$ appsody run --network network_name --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=kafka:9092"`

To shut down Kafka and Zookeeper afterwards, run `docker-compose down`.

#### Running on Kubernetes

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

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init experimental/quarkus
    ```
    This will initialize a Quarkus project using the default template.

    **NOTE:** If you encounter the following error, [configure the experimental repo](#Configuring-Experimental-Repo):

    **`[Error] Repository experimental is not in configured list of repositories`**.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container with Quarkus running in developer mode. Changes to your code (on your local disk) will automatically be detected by Quarkus (running in the container) and will be live reloaded. It also exposes port 8080, for accessing the example REST API and welcome page.

    You can continue to edit the application in your preferred IDE/editor and your changes will be reflected in the running container instantly.

3. You can try your application by visiting http://0.0.0.0:8080/ and observing the welcome page. You can also visit http://0.0.0.0:8080/hello/greeting/paul to try the REST API.

4. To try out the live reload:

    - Edit ./src/main/resources/META-INF/resources/index.html
    - Make a change to the HTML
    - Hit save in your IDE/editor
    - Refresh the page at http://0.0.0.0:8080/

You can also edit `/src/main/java/org/acme/quickstart/GreetingResource.java` and save, the REST API will be live-reloaded on the next invocation.

## Building a Production Image
Running `appsody build` will create a production image that typically boots in under 10ms. Quarkus achieves this fast boot time by using ahead of time compilation of Java into a native executable using [GraalVM](https://www.graalvm.org/). The `appsody build` process can take around 5 minutes due to the amount of time required to build a native executable.

To try this, run:

```bash
appsody build
docker run -i --rm -p 8080:8080 <my-project>:latest
```

Running the production container should give you an output similar to:

```bash
2019-07-16 12:43:21,918 INFO  [io.quarkus] (main) Quarkus 1.3.2.Final started in 0.006s. Listening on: http://0.0.0.0:8080
2019-07-16 12:43:21,918 INFO  [io.quarkus] (main) Installed features: [cdi, resteasy]
```

You can verify that this worked by visiting http://0.0.0.0:8080/ and observing the welcome page. You can also visit http://0.0.0.0:8080/hello/greeting/paul to try the REST API.

## Known Issue:

- Currently there is no configuration or documentation on `appsody debug`.

## Configuring Experimental Repo

Upgrade your CLI to the latest version and add the experimental repo:

1. `brew upgrade appsody` or for other platforms visit the [upgrading appsody section](https://appsody.dev/docs/getting-started/installation).

2. `appsody repo add experimental https://github.com/appsody/stacks/releases/latest/download/experimental-index.yaml`

You should now be able to [initialise your application](#Getting-Started).

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

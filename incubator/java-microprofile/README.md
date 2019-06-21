# Java Microprofile

A stack is the foundation of your application which provides a prototype platform definition for Java Microprifile based projects.

The Java Microprofile stack uses a parent POM to manage dependency versions and provide required capabilities and plugins whilst using Maven. Specifically, this stack enables adoptopenjdk/openjdk8-openj9 and Open Liberty version `19.0.0.5`.

## Templates

Templates are used to create your local project and start your developement. When initializing your project you will be provided with a open liberty sample application by default.

The following capabilities are available from the Java Microprofile templates:

### Health checking

The open liberty sample application comes with in-built Health-checking that enables the cloud platform to determine `liveness` (is your application live or does it need to be restarted?).

Health Check: http://localhost:9080/health

### Application metrics

Enable powerful monitoring for your distributed application. You can monitor metrics to determine the performance and health of a service. You can also use them to pinpoint issues, collect data for capacity planning, or to decide when to scale a service to run with more or fewer resources.

- Metrics: http://localhost:9080/metricsOverHTTP

### Sample Template

The sample template provides you with a simple REST microservice on an Open Liberty server using maven. This template supports the full MicroProfile and Java EE APIs and is composable, meaning that you can use only the features that you need, keeping the server lightweight, which is great for microservices.

## Getting Started

### Initializing the project

1. To start using this Java Microprofile stack you can create a new folder in your local directory and initialize it using with the Appsody CLI eg:
```bash
mkdir <my-project>
cd <my-project>
appsody init java-microprofile
```
This command creates a new project based on the Java Microprofile sample template and then installs your development environment. This will also also install all your applications dependancies into your local .m2 directory.

2. After your project has been intialized you can then run your application using the following command:
```bash
appsody run
```
This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 9080.

Note: you can continue to edit the application in Eclipse or VSCode IDE. Changes will be reflected in the running container around 2 seconds after the changes are saved.

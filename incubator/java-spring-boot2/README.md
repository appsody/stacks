# Spring Boot 2 Stack

The Spring Boot 2 stack supports the development of [Spring Boot 2](https://spring.io/projects/spring-boot) applications using [IBM&#174; SDK, Java Technology Edition, Version 8 with OpenJ9](https://developer.ibm.com/javasdk/) and [Maven](https://maven.apache.org).

## Stacks

A stack is the foundation of your application and provides a prototype platform definition for Spring Boot 2 Java projects. The Spring Boot 2 stack uses a parent Maven project object model (POM) to manage dependency versions and provide required capabilities and plugins. Specifically, this stack enables [Spring Boot Actuator](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-project/spring-boot-actuator), the Prometheus Micrometer reporter, and OpenTracing support for Spring using a Jaeger tracer.

The [Spring Developer Tools](https://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-devtools.html#using-boot-devtools) module is also included to support automatic restarts and live reloading during development.

## Templates

Templates are used to create your local project and start your development.

The default template provides a `pom.xml` file that references the parent POM defined by the stack, and a simple Spring Boot application main class that defines a basic [liveness endpoint](#health-checks-readiness-and-liveness), and a set of unit tests that ensure enabled actuator endpoints work properly: `/actuator/health`, `/actuator/metrics`, `/actuator/prometheus`, and `actuator/liveness`.

## Getting Started

### Initializing the project

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init java-spring-boot2
    ```

    This will initialize a Spring Boot 2 project using the microservice template.

2. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that will run your application in the foreground, exposing it on port 8080. The application will be restarted automatically when changes are detected.

## Health checks, readiness and liveness

Kubernetes defines two integral mechanisms for checking the health of a container:

* A readiness probe is used to indicate whether the process can handle requests (is routable). Kubernetes doesn't route work to a container with a failing readiness probe. A readiness probe should fail if a service hasn't finished initializing, or is otherwise busy, overloaded, or unable to process requests.

* A liveness probe is used to indicate whether the process should be restarted. Kubernetes stops and restarts a container with a failing liveness probe to ensure that Pods in a defunct state are terminated and replaced. A liveness probe should fail if the service is in an irrecoverable state, for example, if an out of memory condition occurs. Simple liveness checks that always return an OK response can identify containers in an inconsistent state, which can happen when process serving requests has crashed but the container is still running.

The Spring Boot 2 Actuator defines an `/actuator/health` endpoint, which returns a {"status": "UP"} payload when all is well. This endpoint is enabled by default, and requires no application code. This actuator works well as a Kubernetes readiness probe, as it automatically includes the status of required resources.

The health endpoint is less useful as a liveness check. In Spring Boot 2, the Actuator framework can be trivially extended with custom endpoints. Your application will include a trivial endpoint to be used as a Kubernetes liveness probe.
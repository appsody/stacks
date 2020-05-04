# Spring® Boot 2 Stack

The Spring Boot 2 stack supports the development of [Spring Boot 2](https://spring.io/projects/spring-boot) applications using OpenJDK 8 and OpenJ9 from [AdoptOpenJDK](https://adoptopenjdk.net/).

The Spring Boot 2 stack uses a parent Maven project object model (POM) to manage dependency versions and provide required capabilities and plugins. Specifically, this stack enables [Spring Boot Actuator](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-project/spring-boot-actuator), the Prometheus Micrometer reporter, and OpenTracing support for Spring using a Jaeger tracer.

The [Spring Developer Tools](https://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-devtools.html#using-boot-devtools) module is also included to support automatic restarts and live reloading during development.

**Note:** Maven is provided by the Appsody stack container, allowing you to build, test, and debug your Java application without installing Maven locally. We recommend installing Maven locally for the best IDE experience.

## Templates

Templates are used to create your local project and start your development.

The default template provides a `pom.xml` file that references the parent POM defined by the stack, and a simple Spring Boot application main class that defines a basic [liveness endpoint](#health-checks-readiness-and-liveness), and a set of unit tests that ensure enabled actuator endpoints work properly: `/actuator/health`, `/actuator/metrics`, `/actuator/prometheus`, and `/actuator/liveness`.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init java-spring-boot2
    ```

    This will initialize a Spring Boot 2 project using the default template.

1. Once your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that will run your application in the foreground, exposing it on port 8080. The application will be restarted automatically when changes are detected.

1. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Health endpoint: http://localhost:8080/actuator/health
    - Liveness endpoint: http://localhost:8080/actuator/liveness
    - Metrics endpoint: http://localhost:8080/actuator/metrics
    - Prometheus endpoint: http://localhost:8080/actuator/prometheus

## Health checks, readiness and liveness

Kubernetes defines two integral mechanisms for checking the health of a container:

* A readiness probe is used to indicate whether the process can handle requests (is routable). Kubernetes doesn't route work to a container with a failing readiness probe. A readiness probe should fail if a service hasn't finished initializing, or is otherwise busy, overloaded, or unable to process requests.

* A liveness probe is used to indicate whether the process should be restarted. Kubernetes stops and restarts a container with a failing liveness probe to ensure that Pods in a defunct state are terminated and replaced. A liveness probe should fail if the service is in an irrecoverable state; for example, if an out of memory condition occurs. 

The Spring Boot 2 Actuator framework defines an `/actuator/health` endpoint, which returns a {"status": "UP"} payload when all is well. This endpoint is enabled by default, and requires no application code. This actuator works well as a Kubernetes readiness probe, as it automatically indicates the status of required resources.

Spring Boot 2 Actuator does not provide a `liveness` endpoint, and the `health` endpoint is less useful as a liveness check. However, the Actuator framework can be easily extended with custom endpoints, like the example liveness endpoint provided by the application template. 

    @Endpoint(id = "liveness")
    @Component
    public class LivenessEndpoint {
    
        @ReadOperation
        public String testLiveness() {
            return "{\"status\":\"UP\"}";
        }

Note that even a simple liveness check that always returns an OK response can help to identify containers in an inconsistent state, which can happen when a process serving requests has crashed but the container is still running.

The starter application produced using this template has a Kubernetes deployment configuration that uses the Spring Boot 2 Actuator `health` endpoint as a Kubernetes `readiness` probe, and uses the template's `liveness` endpoint as a  Kubernetes `liveness` probe.

## Docker image currency

The stack implementation provides for two Docker image specifications, as stack variables declared in the `stack.yaml` file. These are:  

    baseimage: maven:3.6-ibmjava-8
    finalimage: adoptopenjdk/openjdk8-openj9:ubi-jre

The `finalimage` specification determines the image that will be used as the base for the application image. The `baseimage` is used as the base for the stack runtime (a development tool), and also for the "prep" stage of the application image build. By default, as shown above, a Debian image is used for `baseimage` and a Red Hat UBI image is used for `finalimage`. 

The stack implementation provides for optionally updating the packages in these images during the Docker build. By default, packages are not updated in either image. To "turn on" package update, modify the Dockerfile (or Dockerfile-stack) and add the `--system` option to the invocation of `update.sh`. 
```
RUN  /update.sh --system
```

For more information about UBI see:
[Introducing the Red Hat Universal Base Image](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)
 

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

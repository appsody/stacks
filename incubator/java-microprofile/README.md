# Java MicroProfile Stack

The Java MicroProfile stack provides a consistent way of developing microservices based upon the [Eclipse MicroProfile specifications](https://microprofile.io). This stack lets you use [Maven](https://maven.apache.org) to develop applications for [Open Liberty](https://openliberty.io) runtime, that is running on OpenJDK with container-optimizations in OpenJ9.

The Java MicroProfile stack uses a parent Maven project object model (POM) to manage dependency versions and provide required capabilities and plugins.

This stack is based on OpenJDK with container-optimizations in OpenJ9 and `Open Liberty v19.0.0.8`. It provides live reloading during development by utilizing `loose application` capabilities.

The stack also provides a in-built application monitoring dashboard based on [javametrics](https://github.com/runtimetools/javametrics). This dashboard is only included during development and is not included in the image built using `appsody build`.

**Note:** Maven is provided by the Appsody stack container, allowing you to build, test, and debug your Java application without installing Maven locally. However, we recommend installing Maven locally for the best IDE experience.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with an Open Liberty template application.

The default template provides a `pom.xml` file that references the parent POM defined by the stack and enables Liberty features that support [Eclipse MicroProfile 3.0](https://openliberty.io/docs/ref/feature/#microProfile-3.0.html). Specifically, this template includes:

### Health

The `mpHealth` feature allows services to report their readiness and liveness status - UP if it is ready or alive and DOWN if it is not ready/alive. It publishes two corresponding endpoints to communicate the status of liveness and readiness. A service orchestrator can then use the health statuses to make decisions.

Liveness endpoint: http://localhost:9080/health/live
Readiness endpoint: http://localhost:9080/health/ready

### Metrics

The `mpMetrics` feature enables MicroProfile Metrics support in Open Liberty. Note that this feature requires SSL and the configuration has been provided for you. You can monitor metrics to determine the performance and health of a service. You can also use them to pinpoint issues, collect data for capacity planning, or to decide when to scale a service to run with more or fewer resources.

Metrics endpoint: http://localhost:9080/metrics

Log in as the `admin` user with `adminpwd` as the password to see both the system and application metrics in a text format.

### OpenAPI

The `mpOpenAPI` feature provides a set of Java interfaces and programming models that allow Java developers to natively produce OpenAPI v3 documents from their JAX-RS applications. This provides a standard interface for documenting and exposing RESTful APIs.

OpenAPI endpoints:
- http://localhost:9080/openapi (the RESTful APIs of the inventory service)
- http://localhost:9080/openapi/ui (Swagger UI of the deployed APIs)

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:
    ```bash
    mkdir my-project
    cd my-project
    appsody init java-microprofile
    ```

    This will initialize a Java MicroProfile project using the default template. This will also install all parent pom dependencies into your local .m2 directory.

1. Once your project has been initialized, you can run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that starts your application in the foreground, exposing it on port 9080.

    You can continue to edit the application in your preferred IDE (Eclipse, VSCode or others) and your changes will be reflected in the running container within a few seconds.

1. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Readiness endpoint: http://localhost:9080/health/ready
    - Liveness endpoint: http://localhost:9080/health/live
    - Metrics endpoint: http://localhost:9080/metrics (login as `admin` user with `adminpwd` password)
    - OpenAPI endpoint: http://localhost:9080/openapi
    - Swagger UI endpoint: http://localhost:9080/openapi/ui
    - Javametrics Dashboard endpoint: http://localhost:9080/javametrics-dash/ (development-time only)

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

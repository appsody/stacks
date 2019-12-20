# Open Liberty Stack

The Open Liberty stack provides a consistent way of developing microservices based upon the [Jakarta EE](https://jakarta.ee/) and [Eclipse MicroProfile](https://microprofile.io) specifications. This stack lets you use [Maven](https://maven.apache.org) to develop applications for [Open Liberty](https://openliberty.io) runtime, that is running on OpenJDK with container-optimizations in OpenJ9.

The Open Liberty stack uses a parent Maven project object model (POM) to manage dependency versions and provide required capabilities and plugins.

This stack is based on OpenJDK with container-optimizations in OpenJ9 and `Open Liberty v19.0.0.12`. It provides live reloading during development by utilizing the "dev mode" capability in the liberty-maven-plugin.  To see dev mode in action (though not in Appsody) check out this [shorter demo](https://openliberty.io/blog/2019/10/22/liberty-dev-mode.html) and this  [a bit longer demo](https://blog.sebastian-daschner.com/entries/openliberty-plugin-dev-mode).

**Note:** Maven is provided by the Appsody stack container, allowing you to build, test, and debug your Java application without installing Maven locally. However, we recommend installing Maven locally for the best IDE experience.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with an Open Liberty template application.

The default template provides a `pom.xml` file that references the parent POM defined by the stack and enables Liberty features that support [Eclipse MicroProfile 3.2](https://openliberty.io/docs/ref/feature/#microProfile-3.2.html). Specifically, this template includes:

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
    appsody init java-openliberty
    ```

    This will initialize an Open Liberty project using the default template. This will also install all parent pom dependencies into your local .m2 directory.

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

## Stack Usage Notes

1. There is no difference now between the commands: `appsody run` and `appsody debug`, since "run" also launches the Open Liberty server in debug mode.
1. If you launch via `appsody run` then the liberty-maven-plugin will launch dev mode in "hot test" mode, where unit tests and integration tests get automatically re-executed after each detected change.  
1. You can alternatively launch the container with `appsody run --interactive`, in which case the tests will only execute after you input `<Enter>` from the terminal, allowing you to make a set of application and/or test changes, and only execute the tests by pressing `<Enter>` when ready. 
1. The command `appsody test` launches the Open Liberty server, runs integration tests, and then exists with a "success" or "failure" return code (and message).  If you want to run tests interactively, then just use `appsody run`, since dev mode will run allow you to iteratively test and develop interactively.

## Notes to Windows 10 Users

### Shared Drive and Permission Setup 
* See the instructions [here](https://appsody.dev/docs/docker-windows-aad/) for information on setting up "Shared Drives" and permissions to enable mounting the host filesystem from the appsody container.

### Changes from host side not detected by dev mode (on Win10)
Because of an issue in Docker for Windows 10, changes made from the host side to the application may not be detected by the liberty-maven-plugin dev mode watcher running inside the Appsody Docker container, and thus the normal expected compile, app update, test execution etc. may not run.

This problem seems to be resolved for some, though not all users by installing a newer Docker Windows Edge release:  **Docker Desktop Edge 2.1.6.1**.

It may be worked around by making the changes from the host, and then doing a `touch` of the corresponding files from within the container.

See [this issue](https://github.com/OpenLiberty/ci.maven/issues/617) for more tracking information.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

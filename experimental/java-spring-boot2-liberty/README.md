# Spring® Boot 2 With Open Liberty Stack

The Spring Boot 2 stack supports the development of [Spring Boot 2](https://spring.io/projects/spring-boot) applications using OpenJDK 8 and OpenJ9 from [AdoptOpenJDK](https://adoptopenjdk.net/) with Open Liberty.

The Spring Boot 2 stack uses a parent Maven project object model (POM) to manage dependency versions and provide required capabilities and plugins. Specifically, this stack enables [Spring Boot Actuator](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-project/spring-boot-actuator), the Prometheus Micrometer reporter, and OpenTracing support for Spring using a Jaeger tracer.

This stack is based on OpenJDK with container-optimizations in OpenJ9 and `Open Liberty v20.0.0.3`. It provides live reloading during development by utilizing the "dev mode" capability in the liberty-maven-plugin.  To see dev mode in action (though not in Appsody) check out this [shorter demo](https://openliberty.io/blog/2019/10/22/liberty-dev-mode.html) and this  [a bit longer demo](https://blog.sebastian-daschner.com/entries/openliberty-plugin-dev-mode).

**Note:** Maven is provided by the Appsody stack container, allowing you to build, test, and debug your Java application without installing Maven locally. We recommend installing Maven locally for the best IDE experience.

## Templates

Templates are used to create your local project and start your development.

The default template provides a `pom.xml` file that references the parent POM defined by the stack, and a simple Spring Boot application main class that defines a basic [liveness endpoint](#health-checks-readiness-and-liveness), and a set of unit tests that ensure enabled actuator endpoints work properly: `/actuator/health`, `/actuator/metrics`, `/actuator/prometheus`, and `actuator/liveness`.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init java-spring-boot2-liberty
    ```

    This will initialize a Spring Boot 2 on Liberty project using the default template.

1. Once your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that will run your application in the foreground, exposing it on port 9080. The application will be restarted automatically when changes are detected.

1. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Health endpoint: http://localhost:9080/actuator/health
    - Liveness endpoint: http://localhost:9080/actuator/liveness
    - Metrics endpoint: http://localhost:9080/actuator/metrics
    - Prometheus endpoint: http://localhost:9080/actuator/prometheus

## Appsody local development operations: (run/debug/test )

### RUN
If you launch via `appsody run` then the liberty-maven-plugin will launch dev mode in "hot test" mode, where unit tests and integration tests get automatically re-executed after each detected change.  

You can alternatively launch the container with `appsody run --interactive`, in which case the tests will only execute after you input `<Enter>` from the terminal, allowing you to make a set of application and/or test changes, and only execute the tests by pressing `<Enter>` when ready. 
### DEBUG
The `appsody debug` launches the Open Liberty server in debug mode, listening for the debugger on port 7777 (but not waiting, suspended).  Otherwise it allows you to perform the same iteractive, interactive testing as the `appsody run` command.

### TEST
The command `appsody test` launches the Open Liberty server, runs integration tests, and then exits with a "success" or "failure" return code (and message).  If you want to run tests interactively, then just use `appsody run`, since dev mode will run allow you to iteratively test and develop interactively.

## Notes to Windows 10 Users

### Shared Drive and Permission Setup 
* See the instructions [here](https://appsody.dev/docs/docker-windows-aad/) for information on setting up "Shared Drives" and permissions to enable mounting the host filesystem from the appsody container.

### Changes from Windows 10 host side not detected within container
* Because of an issue in Docker for Windows 10, changes made from the host side to the application may not be detected by the liberty-maven-plugin dev mode watcher running inside the Appsody Docker container, and thus the normal expected compile, app update, test execution etc. may not run.
* At the time of the release of this java-openliberty stack, this problem seems to be getting the active attention of the Docker Desktop for Windows developement team, (e.g. see [this issue](https://github.com/docker/for-win/issues/5530)). Naturally, updating your Docker Desktop for Windows installation might help, however, we can not simply point to a recommended version that is known to work for all users.   
* **Workaround**: This may be worked around by making the changes from the host, and then doing a `touch` of the corresponding files from within the container.

## Health checks, readiness and liveness

Kubernetes defines two integral mechanisms for checking the health of a container:

* A readiness probe is used to indicate whether the process can handle requests (is routable). Kubernetes doesn't route work to a container with a failing readiness probe. A readiness probe should fail if a service hasn't finished initializing, or is otherwise busy, overloaded, or unable to process requests.

* A liveness probe is used to indicate whether the process should be restarted. Kubernetes stops and restarts a container with a failing liveness probe to ensure that Pods in a defunct state are terminated and replaced. A liveness probe should fail if the service is in an irrecoverable state, for example, if an out of memory condition occurs. Simple liveness checks that always return an OK response can identify containers in an inconsistent state, which can happen when process serving requests has crashed but the container is still running.

The Spring Boot 2 Actuator defines an `/actuator/health` endpoint, which returns a {"status": "UP"} payload when all is well. This endpoint is enabled by default, and requires no application code. This actuator works well as a Kubernetes readiness probe, as it automatically includes the status of required resources.

The health endpoint is less useful as a liveness check. In Spring Boot 2, the Actuator framework can be trivially extended with custom endpoints. Your application will include a trivial endpoint to be used as a Kubernetes liveness probe.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

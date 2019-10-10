# Rust Rocket Stack

The Rocket stack extends the [Rust stack](../rust/README.md) and provides a consistent way of developing web applications using [Rocket](https://rocket.rs/) applications. Rocket is a fast web framework for Rust that makes it simple to write secure web applications without sacrificing flexibility, usability, or type safety.

This stack is based on the `Rust v1.37` and `Rocket v0.4.2` and allows you to develop new or existing Rocket applications using Appsody.

Currently, debugging is not supported in this stack.

## Health checking

Health-checking enables the cloud platform to determine the `liveness` of your application.

 This is exposed as follows:

- Health check endpoint: http://localhost:8000/health

You can override or enhance the following endpoints by configuring your own health checks in your application.

## Application metrics

Enable powerful monitoring for your distributed application and configure rule-based alerting using Prometheus. This is vital for diagnosing problems and ensuring the reliability of your application.

The `rocket_prometheus` crate provides Prometheus instrumentation for Rocket applications, collects a range of metrics from your application, and exposes them through an application endpoint for Prometheus to scrape and aggregate.

- Metrics endpoint: http://localhost:8000/metrics

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with a simple Rocket application, providing you with a `/` endpoint which returns "Hello from Appsody!". You can then modify this to build out the endpoints required for your application.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init rust-rocket
    ```
    This will initialize a Rocket project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 8000.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

1. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Application root endpoint: http://localhost:8000/
    - Health endpoint: http://localhost:8000/health
    - Metrics endpoint: http://localhost:8000/metrics

## Enabling an existing Project
The Rocket stack can be used with an existing server-side Rocket projects in order to provide an iterative containerized development and test environment, and to "cloud package" it into an optimized production Docker container.
You can enable an existing project as follows:
1. Go to you project directory, e.g.:
    ```bash
    cd my-project
    ```

1. Initialize your Appsody project with the Rocket stack, but without a template:

    ```bash
    appsody init rust-rocket --no-template
    ```

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8000, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

1. You should see your application running at http://localhost:8000/

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license
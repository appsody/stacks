# Python Flask Stack

The Python Flask stack provides a consistent way of developing web applications using [Flask](http://flask.pocoo.org). "Flask is a lightweight WSGI web application framework. It is designed to make getting started quick and easy, with the ability to scale up to complex applications."

This stack is based on Python 3.7 and Flask 0.11.1 and enables health checking and application metrics out of the box. The stack also provides a set of unit tests. The stack also uses [flasgger](https://github.com/rochacbruno-archive/flasgger) to auto-generate swagger ui
documentation and specification.

Remote debugging of applications is enabled during `debug` mode using `ptvsd`, which enables you to connect using the debugger in VS Code. A VS Code debug launch configuration is also provided.

Note that the use of the Python Flask stack requires that `pipenv` is installed, which is used for both version management of Python versions (ensuring you are using the same version locally as used in the stack), and to allow you to specify your own dependencies in a Pipfile.

## Health checking

Health-checking enables the cloud platform to determine `liveness` (is your application alive or does it need to be restarted?) of your application.

 This exposed as follows:

- Health check endpoint: http://localhost:8080/health

You can override or enhance the following endpoints by configuring your own health checks in your application.

## Application metrics

Enable powerful monitoring for your distributed application and configure rule-based alerting using Prometheus. This is vital for diagnosing problems and ensuring the reliability of your application.

The `prometheus_client` module collects a range of metrics from your application, and then expose them as multi-dimensional time-series data through an application endpoint for Prometheus to scrape and aggregate.

This stack also comes with Prometheus metrics, which has been preconfigured to work with your application. You will not be able to override this endpoint:

- Metrics endpoint: http://localhost:8080/metrics

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the simplest Node.js Express application you can write.

This template only has a simple `__init__.py` file which implements the `/hello` endpoint and returns "Hello from Appsody!".

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init python-flask
    ```

    This will initialize a Python Flask project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 8080.

    You can continue to edit the application in your preferred IDE (VSCode or others) and your changes will be reflected in the running container within a few seconds.

1. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Application root endpoint (will redirect to apidocs): http://localhost:8080/
    - Application endpoint: http://localhost:8080/hello
    - Health endpoint: http://localhost:8080/health
    - Metrics endpoint: http://localhost:8080/metrics
    - Swagger API doc: http://localhost:8080/apidocs
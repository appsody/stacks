# Python Flask Stack

The Python Flask stack provides a consistent way of developing web applications using [Flask](http://flask.pocoo.org). "Flask is a lightweight WSGI web application framework. It is designed to make getting started quick and easy, with the ability to scale up to complex applications."

This stack is based on Python 3.7 and Flask 1.1.1 and enables health checking and application metrics out of the box. The stack also provides a set of unit tests. The stack also uses [flasgger](https://github.com/rochacbruno-archive/flasgger) to auto-generate swagger ui documentation and specification.

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

Templates are used to create your local project and start your development. When initializing your project you will be provided with simple python flask application, implemented as a single `__init__.py` file which provides a `/hello` endpoint, which returns "Hello from Appsody!". You can then modify this to build out the endpoints required for your application.

## Getting Started

1. Create a new directory in your local directory and initialize it using the Appsody CLI, e.g.:

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

## Debugging

You can run also your application in debug mode using the following command:

```bash
    appsody debug
```

In debug mode, two aspects are enabled:

1. The flask server is started in development mode, which enables the flask debugger
1. The python debugger for Visual Studio (`ptvsd`) is enabled in the server, enabling remote debugging. The template included in this stack already has a `launch.json` for Visual Studio Code to enable remote debugging attach. This will be placed a directory called `.vscode` in the application directory that you initialize for Appsody. Opening your application in Visual Studio Code should cause this to be loaded.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

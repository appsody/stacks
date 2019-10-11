# Node.js Express Stack

The Node.js Express stack extends the [Node.js stack](../nodejs/README.md) and provides a consistent way of developing web applications using [Express](https://expressjs.com). Express is a fast, minimal and flexible Node.js web application framework that provides a robust set of features for web and mobile applications.

This stack is based on `Node.js v10` and `Express v4.16.0` and enables health checking and application metrics out of the box. The stack also provides a set of tests written using [Mocha](https://mochajs.org) test framework, while the application metadata is provided via a `package.json` file.

## Health checking

Health-checking enables the cloud platform to determine `readiness` (is your application ready to receive requests?) and `liveness` (is your application alive or does it need to be restarted?) of your application.

The [@cloudnative/cloud-health](https://github.com/CloudNativeJS/cloud-health) module is a core library that provides health checking and gives you more control over application lifecycle management (startup, running, shutdown). The [@cloudnative/health-connect](https://github.com/CloudNativeJS/cloud-health-connect) module exposes the health-check information on readiness/liveness endpoints to help the cloud platforms manage your application.

 These endpoints will be available for you to use:

- Readiness endpoint: http://localhost:3000/ready
- Liveness endpoint: http://localhost:3000/live
- Health check endpoint: http://localhost:3000/health

You can override or enhance the following endpoints by configuring your own health checks in your application.

## Application metrics

Enable powerful monitoring for your distributed application and configure rule-based alerting using Prometheus. This is vital for diagnosing problems and ensuring the reliability of your application.

The [appmetrics-prometheus](https://github.com/CloudNativeJS/appmetrics-prometheus) module will collect a wide range of resource-centric (CPU, memory) and application-centric (HTTP request responsiveness) metrics from your application, and then expose them as multi-dimensional time-series data through an application endpoint for Prometheus to scrape and aggregate.

This stack also comes with Prometheus metrics, which has been preconfigured to work with your application. You will not be able to override this endpoint:

- Metrics endpoint: http://localhost:3000/metrics

## Application monitoring dashboard (development only)

During development of your application, the nodejs-express stack provides a built-in application performance dashboard using the [appmetrics-dash](https://github.com/runtimetools/appmetrics-dash) module. This makes it easy to see the resource usage and HTTP endpoint performance of your application as it is developed.

The dashboard is only included during development, and is not included in images build using `appsody build`.

## Templates

Templates are used to create your local project and start your development. This stack provides two templates, simple and scaffold.

Simple, the default template, provides you with a basic Express app and a sample test in a test sub directory.

The scaffold template provides you with an Express application and additional subdirectories for separate routes and views with sample files for each. This gives the user the ability to easily add multiple routes and views, and implement them in the Express application in the `app.js` file provided in this template. This template also comes with a sample test in a test sub directory.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init nodejs-express
    ```

    This will initialize a Node.js Express project using the default template. To initialize a Node.js Express project using the scaffold template substitute the last line above with the following:

    ```bash
    appsody init nodejs-express scaffold
    ```

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 3000.

    You can continue to edit the application in your preferred IDE (VSCode or others) and your changes will be reflected in the running container within a few seconds.

1. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Application endpoint: http://localhost:3000/
    - Health endpoint: http://localhost:3000/health
    - Liveness endpoint: http://localhost:3000/live
    - Readiness endpoint: http://localhost:3000/ready
    - Metrics endpoint: http://localhost:3000/metrics
    - Dashboard endpoint: http://localhost:3000/appmetrics-dash (development only)

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

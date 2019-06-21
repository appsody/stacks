# Node.js Express Stack

This provides a prototype platform definition for Node.js Express based projects. This prototype uses Node.js v10 and Express v4.16.0

## Stacks

A stack is the foundation of your application.

The following capabilities are available form the Node.js Express Stack:

### Health checking

Health-checking enables the cloud platform to determine `readiness` (is your application ready to receive requests?) and `liveness` (is your application live or does it need to be restarted?) of your application.

The [@cloudnative/cloud-health](https://github.com/CloudNativeJS/cloud-health) module is a core library that provides health checking and gives you more control over application lifecycle management (startup, running, shutdown). The [@cloudnative/health-connect](https://github.com/CloudNativeJS/cloud-health-connect) module exposes the health-check information on readiness/liveness endpoints to help the cloud platforms manage your application.

You can override or enhance the following endpoints by configuring your own health checks in `app.js`. If you do not specify a health endpoint thes endpoints will be available for you to use:

- Readiness Check: http://localhost:3000/ready
- Liveness Check: http://localhost:3000/live
- Health Check: http://localhost:3000/health

### Application metrics

Enable powerful monitoring for your distributed application and configure rule-based alerting using Prometheus open source project. This is vital for diagnosing problems and ensuring the reliability of your application.

The [appmetrics-prometheus](https://github.com/CloudNativeJS/appmetrics-prometheus) module will collect a wide range of resource-centric (CPU, memory) and application-centric (HTTP request responsiveness) metrics from your application, and then expose them as multi-dimensional time-series data through an application endpoint for Prometheus to scrape and aggregate.

This stack also comes with prometheus metrics, which has been preconfigured to work with your applicaiton. You will not be able to override this endpoint:

- Metrics: http://localhost:3000/metrics

## Templates

A template is what you will use as a template to begin your developement. When initializing your project you have the option to choose between using the hello-world application or the hello-express application. This stack consists of two nodejs-express templates, A hello-world and a hello-express template.

### simple template

This is the simplest node.js express application you can write. This template only has a simple `app.js` file which implements the `/` endpoint.

### skaffold template

This is typical skaffolding for a basic node.js express application. This template introduces the `routes` and `views` folders, to organize various components of your appplication and has implementation for the `/` endpoint.

## Getting Started

### Initializing the project

1. To start using this Node.js Express stack you can create a new folder in your local directory and initialize it using with the Appsody CLI eg:
```bash
mkdir my-project
cd my-project
appsody init nodejs-express
```
This command creates a new project based on the Node.js Express hello-world Template and then installs your development environment. This will also also install all your applications dependancies.

2. After your project has been intialized you can then run your application using the following command:
```bash
appsody run
```
This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 3000.

Note: you can continue to edit the application in VSCode IDE. Changes will be reflected in the running container around 2 seconds after the changes are saved.

# Pre-release

1. Cloning Appsody stacks repository
```bash
git clone https://github.com/appsody/stacks
```
2. Building the nodejs-express stack
```bash
cd incubator/nodejs-express/stack
docker build -t nodejs-express -f Dockerfile-stack .
```
3. Run your application
```bash
appsody run
```
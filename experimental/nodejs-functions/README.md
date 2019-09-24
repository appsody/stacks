# Node.js Functions Stack

The Node.js Functions stack extends the [Node.js Express stack](../../incubator/nodejs-express/README.md) and provides a way for you to build one or more individual functions using the "Connect Middleware" API from Express.js:

```js
var handler = function handler(req, res, next) {
    res.send('Hello from Appsody!')
}
```

These are then applied onto the pre-configured Express.js from the Node.js Express stack, which provides pre-configured cloud-native capabilities include health checking and application metrics, along with installing a performance monitoring and analysis dashboard during development.

This stack is based on `Node.js v10` and `Express v4.16.0`, as derived from the  [Node.js Express stack](../../incubator/nodejs-express/README.md).

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with a very simple function implementation.

This template only has a simple `function.js` file which implements the `/` endpoint. The application metadata is provided via a package.json file.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init experimental/nodejs-functions
    ```

    This will initialize a Node.js Functions project using the default template.

**NOTE:** If you encounter the following error, [configure the experimental repo](#Configuring-Experimental-Repo):

**`[Error] Repository experimental is not in configured list of repositories`**.

2. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 3000.

    You can continue to edit the application in your preferred IDE (VSCode or others) and your changes will be reflected in the running container within a few seconds.

3. You should be able to access the following endpoints, as they are exposed by your template application by default:

    - Application endpoint: http://localhost:3000/
    - Health endpoint: http://localhost:3000/health
    - Liveness endpoint: http://localhost:3000/live
    - Readiness endpoint: http://localhost:3000/ready
    - Metrics endpoint: http://localhost:3000/metrics
    - Dashboard endpoint: http://localhost:3000/appmetrics-dash (development only)

## Developing a function

The functions you create use the familiar "Connect Middleware" API, with `request`, `response` and `next` as the function parameters. When creating a function, you must also export a `url` symbol, with the URL you want to register the function against, as well as export the function itself using the name of the HTTP verb you want to register with as the symbol.

In the following example, the function is registered for `get` requests on `/`

```js
module.exports.url = '/'
module.exports.get = function(req, res, next) {
    res.send('Hello from Appsody!')
}
```

If you wish to have multiple functions as part of your project, simply create an additional `.js` file in your folder to contain the function.

Note that you can also `require` any modules that you wish to use but adding them to the `package.json` and adding a `require` statement into your function files as you would normally.

## Configuring Experimental Repo

Upgrade your CLI to the latest version and add the experimental repo:

1. `brew upgrade appsody` or for other platforms visit the [upgrading appsody section](https://appsody.dev/docs/getting-started/installation).

2. appsody repo add experimental https://github.com/appsody/stacks/releases/latest/download/experimental-index.yaml

You should now be able to [initialise your application](#Getting-Started).

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

# Node.js Stack

The Node.js stack provides a consistent way of developing [Node.js](https://nodejs.org/) applications. As an asynchronous event-driven JavaScript runtime, Node is designed to build scalable network applications.

This stack is based on the `Node.js v12` runtime and allows you to develop new or existing Node.js application using Appsody.

Additionally, if you are developing an application that includes a HTTP server or a web framework such as Express.js,the stack provides a built-in application performance dashboard using the [appmetrics-dash](https://github.com/runtimetools/appmetrics-dash) module. This makes it easy to see the resource usage and HTTP endpoint performance of your application as it is developed.

The dashboard is only included during development, and is not included in images build using `appsody build`.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a simple application that logs a message to the console. The application metadata is provided via a `package.json` file.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init nodejs
    ```

    This will initialize a Node.js project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 3000, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

1. You should see a message printed on the console:

    ```Hello from Node.js 12!```

    **NOTE:** Currently the `appsody deploy` command only works for deploying web applications.

## Customizing the build

Simple Node projects do not require a 'build' process: they are executed directly from source.  However, some technologies such as TypeScript require commands to be invoked to prepare the project ready to be run.

If your project's dependencies require an additional build step, you can do so as follows:

- In your `package.json`, edit the `"scripts"` section and define two new scripts:
  - `"build": "npm install && <build commands>"`
  - `"prune": "<cleanup commands> && npm prune"`

When initially launching your app using `appsody run`, or building the production image with `appsody build`, the 'build' script is executed (if one exists).  Your build script should invoke `npm install` if any dependencies specified in your `devDependencies` are required as part of the build process - such as command line tools.

When generating the production image, the 'prune' script is executed after that, if it exists, and is run with the `--production` flag.  This allows the removal of development dependencies that were required during the 'build' step.  This could be as simple as running the `npm prune` command, which inherits the production flag, and restores the dependencies to a production state.  You may also use this step to clean up any build artifacts that are not necessary in your production image.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

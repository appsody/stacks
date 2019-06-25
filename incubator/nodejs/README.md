# Node.js Stack

The Node.js stack provides a consistent way of developing [Node.js](https://nodejs.org/) applications. As an asynchronous event-driven JavaScript runtime, Node is designed to build scalable network applications.

This stack is based on `Node.js v10` runtime and allows you to bring any Node.js application that can work with this version of the runtime.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the simplest Node.js application you can possibly write.

The default template provides a simple application that logs a message to the console. The application metadata is provided via a `package.json` file.

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

    This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 3000.

    You can continue to edit the application in your preferred IDE (VSCode or others) and your changes will be reflected in the running container within a few seconds.

1. You should see a message printed on the console:

    ```Hello from Node.js 10!```
# Swift Stack

The Swift stack is designed to provide a foundation for building and running Swift applications in Appsody.

This stack is based on the `Swift 5.0` runtime and allows you to develop new or existing Swift applications using Appsody.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a simple application that prints "Hello World".

## Getting Started for a new Project

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init swift
    ```
    This will initialize a Swift project using the default template.

2. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8080, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

3. You should see a message printed on the console:

    ```bash
    Hello, world!
    ```

**NOTE:** Currently the `appsody deploy` command only works for deploying web applications.

## Enabling an existing Project

The Swift stack can be used with an existing server-side Swift project in order to provide an iterative containerized development and test environment, and to "cloud package" it into an optimized production Docker container.

You can enable an existing project as follows:

1. Go to you project directory, e.g.:

    ```bash
    cd my-project
    ```
    
2. Initialize your Appsody project with the Swift stack, but without a template:

    ```bash
    appsody init swift --no-template
    ```

3. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8080, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

3. You should see your application run, with logs written to the console.

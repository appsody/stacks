# Go Stack using Go Modules vendoring

This stack provides a consistent way of developing [Golang](https://https://golang.org/) applications using the [Go Modules](https://github.com/golang/go/wiki/Modules) vendoring method. 

This stack is based on the `Go v1.12.5` runtime and allows you to develop new or existing Go applications using Appsody.


## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a simple application that logs a message to the console. 

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init go-modules 
    ```
    This will initialize a Go project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

1. You should see a message printed on the console:

    ```Hello, world!```

    **NOTE:** Currently the `appsody deploy` command only works for deploying web applications.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

## Notes

Please note that this stack does not currently support debugging.

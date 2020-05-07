# Rust Stack

The Rust stack provides a consistent way of developing [Rust](https://rust-lang.org/) applications.

This stack is based on the `Rust v1.39` runtime and allows you to develop new or existing Rust applications using Appsody.

The Rust stack uses [Rust MUSL support](https://doc.rust-lang.org/edition-guide/rust-2018/platform-and-target-support/musl-support-for-fully-static-binaries.html) to build fully static binaries with statically linked libc, making the built images really small.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a simple application that prints "Hello from Appsody!".

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init rust
    ```
    This will initialize a Rust project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8000, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

1. You should see a message printed on the console:

    ```Hello from Appsody!```

    **NOTE:** Currently the `appsody deploy` command only works for deploying web applications.

## Enabling an existing Project

The Rust stack can be used with an existing server-side Rust projects in order to provide an iterative containerized development and test environment, and to "cloud package" it into an optimized production Docker container.

You can enable an existing project as follows:

1. Go to you project directory, e.g.:

    ```bash
    cd my-project
    ```

2. Initialize your Appsody project with the Rust stack, but without a template:

    ```bash
    appsody init rust --no-template
    ```

3. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8000, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

3. You should see your application run, with logs written to the console.

## Debugging

To debug your application running in a container, start the container using:

```bash
    appsody debug --docker-options "--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
```

The command will start the LLDB platform and wait for incoming connections from any address to port 1234. 

You can use the `launch.json` provided to debug in the VS Code IDE. Alternatively, you can connect `lldb` in remote debug mode to this container as follows:

```bash
lldb \
  -o "platform select remote-linux" \
  -o "platform connect connect://localhost:1234" \
  -o "platform settings -w /project/user-app/target/debug" \
  -o "file rust-simple" 
```

Once in lldb, you can use `breakpoint set` to set breakpoints in your application, and then `run` to start the app.

**NOTE:** Due to a current limitation, breakpoints must be set _before_ the application is run. Breakpoints can be disabled, but cannot be re-enabled without restarting the app. After adding or re-enabling breakpoints, restart the app with `process kill` and then `run`.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license
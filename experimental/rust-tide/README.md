# Rust Tide Stack

The Rust Tide stack provides a consistent way of developing [tide](https://github.com/http-rs/tide) http servers.

<<<<<<< HEAD
This stack is based on the `Rust 1.42` runtime.
=======
This stack is based on the `Rust nightly` runtime.
>>>>>>> 701d3b36d91c44214c393ca22655e069b3e92c7d

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a http server that returns "Hello World" on http://localhost:8000/hello.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init rust-tide
    ```
    This will initialize a Tide project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8000 to allow you to call your service from your browser and test tooling.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

1. You should see a message printed on the console:

    ```Running `server/bin/target/debug/rust-tide-server```

## Debugging

To debug your application running in a container, start the container using:

```bash
    appsody debug --docker-options "--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
```

The command will start the LLDB platform and wait for incoming connections from any address to port 1234. 

You can connect `lldb` in remote debug mode to this container as follows:

```bash
lldb \
  -o "platform select remote-linux" \
  -o "platform connect connect://localhost:1234" \
  -o "platform settings -w /project/userapp/target/debug" \
  -o "file rust-tide-server" 
```

Once in lldb, you can use `breakpoint set` to set breakpoints in your application, and then `run` to start the app.

**NOTE:** Due to a current limitation, breakpoints must be set _before_ the application is run. Breakpoints can be disabled, but cannot be re-enabled without restarting the app. After adding or re-enabling breakpoints, restart the app with `process kill` and then `run`.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license
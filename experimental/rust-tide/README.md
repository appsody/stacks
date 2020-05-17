# Rust Tide Stack

The Rust Tide stack provides a consistent way of developing [tide](https://github.com/http-rs/tide) http servers.

Designed to be used with [Appsody](https://appsody.dev/) an [open source](https://github.com/appsody/) development and operations accelerator for containers.

This stack is based on the `Rust 1.42` runtime.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a http server that returns "Hello World" on http://localhost:8000/hello.

## Getting Started

1. Clone this repo and configure appsody
   ```bash
   git clone https://github.com/No9/rust-tide
   cd rust-tide
   appsody stack package
   ```

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init dev.local/rust-tide
    ```
    This will initialize a Tide project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8000 to allow you to call your service from your browser and test tooling.

1. You should see a message printed on the console:

    ```Running `server/bin/target/debug/rust-tide-server```

1. Open a browser at http://localhost:8000/hello 
     
     It should return `Hello, world`.

1. Now open lib.rs and change `world` to `tide` and save the file.

    ```rust
    pub fn app() -> tide::server::Server<()> {    
        let mut api = tide::new();
        api.at("/hello").get(|_| async move { "Hello, Tide" });
        api
    }
    ```

1. Your application will be rebuild and republished so refresh http://localhost:8000/hello it will now say `Hello, Tide`


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
  -o "platform settings -w /project/server/bin/target/debug" \
  -o "file rust-tide-server" 
```

Once in lldb, you can use `breakpoint set` to set breakpoints in your application, and then `run` to start the app.

**NOTE:** Due to a current limitation, breakpoints must be set _before_ the application is run. Breakpoints can be disabled, but cannot be re-enabled without restarting the app. After adding or re-enabling breakpoints, restart the app with `process kill` and then `run`.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license
# Rust Tide Stack

The Rust Tide stack provides a consistent way of developing [tide](https://github.com/http-rs/tide) http servers.

Designed to be used with [Appsody](https://appsody.dev/) an [open source](https://github.com/appsody/) development and operations accelerator for containers.

This stack is based on the `Rust 1.45.0-buster` runtime release.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a http server that returns "Hello World" on http://localhost:8000/.

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init experimental/rust-tide
    ```
    This will initialize a Tide project using the default template.

1. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8000 to allow you to call your service from your browser and test tooling.

1. You should see a message printed on the console:

```
    [Container] Server running on: http://localhost:8000/
```

1. Open a browser at http://localhost:8000/
     
     It should return `Hello, world`.

1. Now open lib.rs and change `world` to `Tide` and save the file.

    ```rust
        pub fn app() -> tide::Server<()> {    
            let mut api = tide::new();
            api.at("/").get(|_| async move { Ok("Hello, Tide!") });
            api
        }
    ```

1. Your application will rebuild and republish so refresh http://localhost:8000/ it will now say `Hello, Tide`


## Debugging

This stack is configured to run a remote gdb server in the app container. 
You can connect to the gdb server on localhost:1234 with the tools of your choice.
However the stack also comes preconfigured to integrate with VSCode and you can debug the application with the following steps:

1. Start the container in debug mode
   This is done by pressing `CTRL + SHFT + B` and selecting `Appsody: debug` 
   Or through the menu option `Terminal --> Run Task --> Appsody: debug`
   The command will start the the app with the gdb server and wait for incoming connections from any address to port 1234. 

2. Run the Appsody copy task to get the symbols for the the local debugger.
   This is done by pressing `CTRL + SHFT + B` and selecting `Appsody: copy` 
   Or through the menu option `Terminal --> Run Task --> Appsody: copy`
    
3. Now we can debug the program with pressing `F5`
   Or through the menu option `Run --> Start Debugging`

4. See https://code.visualstudio.com/docs/cpp/cpp-debug for more information on using the debugger.

If the debugger returns an error like 
```
Unable to start debugging. Launch options string provided by the project system is invalid. Unable to determine path to debugger...
```
You may need to install `gdb` on your system. 
See Linux(https://code.visualstudio.com/docs/cpp/config-linux), [Mac](https://code.visualstudio.com/docs/cpp/config-clang-mac), [Windows](https://code.visualstudio.com/docs/cpp/cpp-debug#_windows-debugging-with-gdb) for OS specific information.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license
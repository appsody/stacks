# Kitura Stack

The [Kitura](https://kitura.io) stack extends the [Swift stack](../swift/README.md).  Kitura is an open source web framework for server-side Swift that can be used to build web applications and REST APIs, with full support for databases, WebSockets, OpenAPI and much more.

## Templates

Templates are used to create your local project and start your development. When initializing your project you will be provided with the default template project. This template provides a simple application that hosts the Kitura landing page, and an example route on `/hello` which returns a simple greeting.

## Getting Started for a new Project

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

    ```bash
    mkdir my-project
    cd my-project
    appsody init kitura
    ```
    This will initialize a Kitura project using the default template.

2. After your project has been initialized you can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8080, to allow you to interact with your application.

    You can continue to edit the application in your preferred IDE (VSCode, Xcode or others) and your changes will be reflected in the running container within a few seconds.

3. If you navigate to http://localhost:8080 you will see the Kitura landing page.

## Facilities provided by the stack

The `kitura` stack provides a number of predefined routes for your application:
- `/health`: the liveness endpoint
- `/metrics`: the Prometheus metrics endpoint
- `/openapi`: the OpenAPI definition for your server, describing all Codable routes
- `/openapi/ui`: the SwaggerUI allowing you to inspect and test your routes.

The project's dependencies include `AppsodyKitura`, a package provided by the stack that includes the `Kitura`, `HeliumLogger` and `Configuration` packages.  These are available to be imported by your application and you do not need to declare a dependency on them explicitly.

**NOTE:** You should not remove or modify the `AppsodyKitura` dependency.

## Enabling an existing Project

The Kitura stack can be used with an existing Kitura project in order to provide an iterative containerized development and test environment, and to "cloud package" it into an optimized production Docker container.

You can enable an existing project as follows:

1. Go to you project directory, e.g.:

    ```bash
    cd my-project
    ```

2. Initialize your Appsody project with the Swift stack, but without a template:

    ```bash
    appsody init kitura none
    ```

3. Add the `AppsodyKitura` dependency to your `Package.swift`:

In your package dependencies:
    ```diff
    dependencies: [
-      .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.8.0")),
+      .package(path: ".appsody/AppsodyKitura"),
      // Place any additional dependencies here
    ],
    ```
Note: AppsodyKitura provides the `Kitura`, `HeliumLogger`, `Kitura-OpenAPI`, `SwiftMetrics` and `Configuration` dependencies. You may remove these dependencies if your existing project declared them.

In your application's target:
    ```diff
    targets: [
      .target(name: "my-project", dependencies: [ .target(name: "Application") ]),
      .target(name: "Application", dependencies: [
+          "AppsodyKitura",
          // Any additional dependencies
      ]),
    ]
    ```

In your application:
    ```diff
-    let router = Router()
+    let router = AppsodyKitura.createRouter()
    ```
Note: the router provided by AppsodyKitura is pre-initialized with the liveness, metrics and OpenAPI routes as required by the stack. If your existing application added these routes manually, you must remove them.

4. You can then run your application using the following command:

    ```bash
    appsody run
    ```

    This launches a Docker container that continuously re-builds and re-runs your project. It also exposes port 8080, to allow you to bring your own web application and use it with this stack.

    You can continue to edit the application in your preferred IDE (VSCode or other) and your changes will be reflected in the running container within a few seconds.

3. You should see your application run, with logs written to the console.

## Debugging

To debug your application running in a container, start the container using:
```bash
appsody debug --docker-options "--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
```

You can connect `lldb` in remote debug mode to this container as follows:
```bash
lldb \
  -o "platform select remote-linux" \
  -o "platform connect connect://localhost:1234" \
  -o "file .build/debug/server" \
  -o "env LD_LIBRARY_PATH=/project/user-app/.build/debug"
```

Once in lldb, you can use `breakpoint set` to set breakpoints in your application, and then `run` to start the app.

**NOTE:** Due to a current limitation, breakpoints must be set _before_ the application is run. Breakpoints can be disabled, but cannot be re-enabled without restarting the app. After adding or re-enabling breakpoints, restart the app with `process kill` and then `run`.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

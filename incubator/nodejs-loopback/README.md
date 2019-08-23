# Node.js LoopBack Stack

The Node.js LoopBack stack extends the [Node.js stack](../nodejs) and provides a
powerful solution to build open APIs and Microservices in TypeScript with
[LoopBack](https://loopback.io/), an open source Node.js API framework. It is
based on [LoopBack 4](https://github.com/strongloop/loopback-next).

## Image

The image contains the main code that loads the user application and configures
with cloud native components such as `@loopback/extension-health` which exposes
`/health` endpoint for health checks.

The project layout is structured as follows:

```
/project/ (main)
  package.json
  src/
    index.ts (importing user-app)
  dist/ (transpiled js code)
  ...
  user-app/ (code from the nodejs-loopback/templates/scaffold)
    package.json
    ...
```

## Templates

- `scaffold`: The template is generated with `lb4` command from `@loopback/cli`.
  See https://loopback.io/doc/en/lb4/Getting-started.html for more information.

## Getting Started

1. Create a new folder in your local directory and initialize it using the
   Appsody CLI, e.g.:

   ```bash
   mkdir my-project
   cd my-project
   appsody init nodejs-loopback
   ```

   This will initialize a Node.js LoopBack project using the default template.

2. After your project has been initialized you can then run your application
   using the following command:

   ```bash
   appsody run
   ```

   This launches a Docker container that continuously re-builds and re-runs your
   project, exposing it on port 3000.

   You can continue to edit the application in your preferred IDE (VSCode or
   others) and your changes will be reflected in the running container within a
   few seconds.

## Test the stack locally

```sh
cd nodejs-loopback
cd image

# Choose org-name (such as appsody) and version (such as 0.1.0)
docker build -t <org-name>/nodejs-loopback:<version> -f Dockerfile-stack .

cd ../templates/scaffold
# Make sure `.appsody-config.yaml` to use your built stack, such as:
# stack: appsody/nodejs-loopback:0.1.0

# Run the tests
appsody test

# Create and run an application from the stack
appsody run
```

See https://appsody.dev/docs/stacks/modify for more details.

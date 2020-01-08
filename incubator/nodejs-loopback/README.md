# Node.js LoopBack Stack

The Node.js LoopBack stack extends the [Node.js stack](../nodejs) and provides a
powerful solution to build open APIs and Microservices in TypeScript with
[LoopBack](https://loopback.io/), an open source Node.js API framework. It is
based on [LoopBack 4](https://github.com/strongloop/loopback-next).

## Image

The image contains the main code that loads the user application and configures
with the following components to help the application become cloud native:

- `@loopback/extension-health`: exposes `/health` endpoint for health checks
  including with `/ready` for readiness and `/live` for liveness checks.

- `@loopback/extension-metrics`: exposes `/metrics` endpoint for metrics data
  that can be scraped by (Prometheus)[https://prometheus.io/].

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

   You should now be able to access the following endpoints, as they are exposed by your application by default:

   - Application endpoint: http://localhost:3000/
   - API explorer: http://localhost:3000/explorer
   - Open API Spec: http://localhost:3000/openapi.json
   - API endpoint: http://localhost:3000/ping
   - Health endpoint: http://localhost:3000/health
   - Liveness endpoint: http://localhost:3000/live
   - Readiness endpoint: http://localhost:3000/ready
   - Metrics endpoint: http://localhost:3000/metrics

   You can continue to edit the application in your preferred IDE (VSCode or
   others) and your changes will be reflected in the running container within a
   few seconds.

See https://appsody.dev/docs/stacks/modify for more details.

## License

This stack is licensed under the [Apache 2.0](./image/LICENSE) license

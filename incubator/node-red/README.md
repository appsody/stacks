# Node-RED Appsody Stack

This is a stack for building a deployable Node-RED application using [Appsody](https://appsody.dev).

The resulting application will run the Node-RED flows in a headless mode without
the editor enabled.

The stack builds a standard set of cloud-native endpoints into the application
to determine its `readiness` and `liveness`. These are exposed as:

 - Readiness endpoint: http://localhost:3000/ready
 - Liveness endpoint: http://localhost:3000/live
 - Health check endpoint: http://localhost:3000/health

The stack is based on the Node.js v12 runtime.

## Templates

This stack provides a single template - `simple`. It is a minimal template
with a default flow file to get started with. However, the typical usage will be
to take an existing Node-RED project and package it ready for deployment.

## Getting Started

The stack is designed to augment an existing Node-RED project.

A typical Node-RED project will have the structure:

```
├── README.md
├── flow.json
├── flow_cred.json
├── package.json
└-- settings.js
```

The `package.json` file will have the structure:
```
{
    "name": "AppsodyProject",
    "description": "A Node-RED Project",
    "version": "0.1.0",
    "dependencies": {},
    "node-red": {
        "settings": {
            "flowFile": "flow.json",
            "credentialsFile": "flow_cred.json"
        }
    }
}
```

This stack will use the `package.json` file to install any additional dependencies
the project has and also to identify the flow file - using the `node-red` section.

If the `package.json` file doesn't have `node-red` section, the stack will use
`flow.json` as the default flow file.


The `settings.js` file is a normal Node-RED settings file, but the stack will override
some of the values:

 - If running in development mode, `httpAdminRoot` is set to `/admin`.
 - Otherwise, if `NODE_ENV` is set to `production`, the editor and Admin API will
   be disabled entirely.


Given this structure, the following steps can be used to use the stack:

1. Initialise it using the Appsody CLI:

    ```bash
    appsody init incubator-index/node-red none
    ```

    When initialising an existing project, the `none` template must be used.


2. Once it has been initialised, you can then run the application using:

    ```bash
    appsody run
    ```

    This launches a Docker container, exposing it on port 3000.

# Stacks Release Process

This document outlines the process for building, testing and releasing Appsody stacks. 

`appsody/stacks` contains multiple stacks repos such as `experimental`, `incubator` and `stable`. Each repo includes several stacks. The build process allows you to build and release each stack and the indexes for each stack repo. 

[Travis-CI](https://travis-ci.org) is configured to build and test the stacks and indexes on GitHub pull requests. When a GitHub release is created manually, the built and tested stacks and indexes are published on DockerHub and GitHub releases. 

## Build

The `build.sh` script is a wrapper created for convenience and covers the process of identifying which stacks need to be built, builds stack images and templates, generates all repo indexes and then tests the stacks and indexes locally. 

### List

This script decides which stacks need to be built and exposes that list as an environment variable called **STACKS_LIST** which contains a space-separated list of `repo/stack`.

Example:
```
STACKS_LIST=incubator/nodejs incubator/nodejs-express experimental/nodejs-functions
```

The script makes use of several Travis environment variables to determine which stacks should be built:
1. In a pull request build, it lists stacks with modified or new `stack.yaml` files
1. In a release build, it looks at the release tag and builds only the stack with matching id.
1. If none of these criteria is matched, it will include all stacks.

### Package

`package.sh` script iterates over each repository (`experimental incubator stable`) and creates indexes for each repository. The indexes are based on `stack.yaml` file for each stack. It then iterates over the **STACKS_LIST** environment variable and for each stack does the following:
- build docker image of the stack
- tags the images with right labels based on the stack version
- creates template archives for each template

### Test

`test.sh` script is currently being implemented. It will run tests for each stack using the assets created by the `package.sh` script.

## Release

 The release process is invoked when a GitHub release is created with a tag manually. The tag must follow the `<name>-v<version>` format, for example: `java-microprofile-v0.2.1`. Currently, we create a release for each stack version. This triggers a Travis that builds, tests and publishes the stack being released. 

`release.sh` script iterates over the **STACKS_LIST** environment variable to determine which stack need to be released and then publishes the template archives for that stack as GitHub release assets and publishes the stack images on [Appsody dockerhub](https://hub.docker.com/u/appsody). It also publishes all repo indexes as GitHub release assets.

# Appsody Stacks Release Process
A release in this repo represents a new version of a particular stack - denoted by the release tag. It will contain the following assets:
- archives for all the templates for the released stack on [GitHub releases](https://github.com/appsody/stacks/releases)
- latest indexes for each of the repos (`incubator`, `experimental`, `stable`) on [GitHub releases](https://github.com/appsody/stacks/releases)
- updated docker hub images with appropriate tags on [dockerhub](https://hub.docker.com/u/appsody)

## Steps to create a new stack release
The Appsody stacks are made available by creating a tagged GitHub release. Follow these steps to create a new release of an Appsody stack:

### Trigger the release on GitHub
1. Navigate to https://github.com/appsody/stacks/releases
1. Click _Draft a new release_ button
1. Ensure the target branch is __master__
1. Define a tag in the format `<stack-id>-v<version>` (example: java-microprpfile-v0.2.4)
1. Set a title in the format `<stack-id> v<version>` (example: java-microprofile v0.2.4)
1. Describe the notable changes to the stack as release notes
1. Tick _This is a pre-release_ checkbox
1. Click _Publish release_ button

### Monitor the Travis build
1. Watch the [Travis build](https://travis-ci.com/appsody/stacks) for the release and ensure it passes
1. Check the release artefacts to ensure these all exist:
    - archives for all the templates for the released stack on [GitHub releases](https://github.com/appsody/stacks/releases)
    - latest indexes for each of the repos (`incubator`, `experimental`, `stable`) on [GitHub releases](https://github.com/appsody/stacks/releases)
    - updated docker hub images with appropriate tags on [dockerhub](https://hub.docker.com/u/appsody)

### Update the pre-release
1. Navigate to https://github.com/appsody/stacks/releases
1. Click on the title of the pre-release you have just created
1. Click _Edit release_ button
1. Untick _This is a pre-release_ checkbox
1. Click _Edit release_ button

### Update v1 Index
1. For now we are manually updating the [old appsody stacks index](https://github.com/appsody/stacks/blob/master/index.yaml)
1. Create a pull request to update this file and update the index manually for the updated stack. Ususally, we only need to update the `version` and `url` fields for the updated stack
1. Submit the pull request
1. Once the pull request is approved, merge the changes


# Releasing Dependent Stacks
There is no fixed release schedule for Appsody stacks. Stacks should be released as we merge pull requests in this repo.

If a stack is consumed by other stacks, then we must also update the dependent stacks and release new versions of those. For example, a change to `nodejs` stack will need a new release of `nodejs`, followed by a new release of `nodejs-express`.

# Appsody Stacks Release Process - Technical Overview

This document outlines the process for building, testing and releasing Appsody stacks.

`appsody/stacks` contains multiple stacks repos such as `experimental`, `incubator` and `stable`. Each repo includes several stacks. The build process allows you to build and release each stack and the indexes for each stack repo.

[Travis-CI](https://travis-ci.org) is configured to build and test the stacks and indexes on GitHub pull requests. When a GitHub release is created manually, the built and tested stacks and indexes are published on DockerHub and GitHub releases.

## Build Phase

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

## Release Phase

 The release process is invoked when a GitHub release is created with a tag manually. The tag must follow the `<name>-v<version>` format, for example: `java-microprofile-v0.2.1`.

`release.sh` script iterates over the **STACKS_LIST** environment variable to determine which stack need to be released and then publishes the template archives for that stack as GitHub release assets and publishes the stack images on [Appsody dockerhub](https://hub.docker.com/u/appsody). It also publishes all repo indexes as GitHub release assets.
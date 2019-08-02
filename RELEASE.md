# Stacks Release Process

This document outlines the process for releasing stacks.

## Build release

When a pull request is opened on the `appsody/stacks` repo the TravisCI is triggered. The Travis builds the Appsody stacks, packages the all the templates and runs the tests for new stacks or stacks that have been modified.

## Check

Firstly this script checks whether the TravisCI has been triggered by a pull request. If the script is running inside a pull request then then the script will check for any modified or new `stack.yaml` files, it will then return a list containing all the `repo/stacks` that have been changed. It will expose that list to an environment variable called **STACKS_LIST**. If the script is been run locally it will return a list of all the stacks to the same environment variable.

Example:

```
STACKS_LIST=incubator/nodejs incubator/nodejs-express experimental/nodejs-functions
```

## Package

At the moment the script iterates over each repository (experimental incubator stable) and creates an index for each repository (**stable**, **incubator** and **experimental**) . It then utilises the **STACK_LIST** ennvironment variable that is exposed by the [check script](#check-script)  and does a **docker build** only for the stacks in that list. It then updates the **index.yaml** files pointing to the newly built images. The templates are packaged and built for for every stack.

## Test

Uses the assets in the test directory and runs stacks tests...

## Release

To kick off a stacks release go to the releases section of the stacks repository. You should tag the release witht the stack you want to release, for example: `java-microprifle:0.3.0`. The release script will pick up the tag and only build and release the stack you have specified in the release tag. each release includes the three `index.yaml` files and the packaged template of the stack you have released. Additionally it builds the latest, the lastest major version, the latest minor version and the latest patch version of the stack and pushes them to the [appsody docker hub](https://hub.docker.com/u/appsody) registry. 

At the moment we mark each release as a pre-release because...

## Local Release

clone the stacks repo
```bash
git clone https://github.com/appsody/stacks.git
```

whilst inside the ci folder run build script and specify the root directory
```bash
. ./build.sh ../
```

to run each section individually run
```

```

## Limitations
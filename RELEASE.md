# Stacks Release Process

This document outlines the process for releasing stacks.

## Build release

When a pull request is opened on the `appsody/stacks` repo the TravisCI is triggered. The Travis builds the Appsody stacks, packages the all the templates and runs the tests for new stacks or stacks that have been modified.

the pull request is a change off the build script which in turn runs the build package and release scripts.

## Check script

Checks whether you are running inside TravisCI; checks whether or not it is a pull request .. or running the script locally. If you are running then it'll check for any stacks that have been modified - > checks if a `stack.yaml` has been edited  

Checks if a stack.yaml has being modifyied then returns a list of stacks that changed based on 
## Package

At the moment it always packages everything up but we want to further optimise this when we have an object..
packages up the templates and generates the new index.yaml for **stable**, **incubator** and **experimental** 

## Test

Uses the assets in the test directory and runs stacks tests...

## Release

When a stack release happens it pushes the stacks new updated images - > does a docker push to the appsody dockerhub repo,

## Releasing Stacks locally

clone the stacks repo
```bash
git clone https://github.com/appsody/stacks.git
```

whilst side the ci folder run build script and specify the root directory
```bash
. ./build.sh ../
```

to run each section individually run
```

```
## Limitations
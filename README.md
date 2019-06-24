# Stacks

This respository holds the default set of stacks avalible from the Appsody CLI. Stacks allow for rapid development whilst giving the stack developer the ability to control the overall applications that are created from it. Stacks are make up of a image and one or more templates.

**Image:** An image is the foundation for your application. It sets the default functionality and controls what can be overwritten by a template or application based on it.

**Template:** A template is based on a image and provides a starter application that is ready to use. It has access to any dependencies supplied by that image and is able to include extra dependencies plus new functionality to enhance the stack where allowed.

For more information on how to create a stack from scratch along with what is expected at each stage for it to be considered a stack go to [creating or modifying](https://github.com/appsody/stacks/blob/master/docs/create-or-modify.md) stacks.

## Using Stacks
1. Create a new directory
``` bash
mkdir my-app &&
cd my-app
```
2. Initalise Appsody stack
``` bash
appsody init java-microprofile
```
3. Launch application in development environment
``` bash
appsody run
```

Note: to list all available Appsody stacks run `appsody list`.

## Repository Structure
Stacks are catagorised as either `stable`, `incubator` or `experimental` depending on the content of the stack.

- `stable/`: Stable stacks meet a set of technical requirements which are yet to be defined.

- `incubator/`: The incubator folder allows stacks to be shared and improved on until they meet the stable critria.

- `experimental/`: These stacks are labeled experimental as they may not fulfill the requirements of a appsody stack. Experimental stacks are also not expected to move out of this category into incubator or stable.

For infomation on moving a stack to a different folder check out the [stacks overview](https://github.com/appsody/stacks/blob/master/docs/stacks-overview.md)

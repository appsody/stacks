# Stacks

This respository holds the default set of stacks avalible from the appsody cli. Stacks allow for rapid development whilst giving the stack developer the ability to control the overall applications that are created from it. A stack is make up of a stack and one or more templates.

**Stack:** A stack is the foundation for your application. A stack can set default functionality and controls what can be overwritten by a template or application based on it.

**Template:** A template is based upon a stack providing a template application that is ready to use. It has access to any dependencies supplied by that stack and is able to include extra dependencies plus new functionality to enhance the stack where allowed.

## Getting started with Stacks
1. Create app directory
``` bash
mkdir my-app && cd my-app
```
2. Initalise Appsody stack with template
``` bash
appsody init <stack>/<template>
```
3. Launch application in development environment
``` bash
appsody run
```

## Creating a Stack
The [creating a stack](https://github.com/appsody/stacks/blob/master/docs/creating-a-stack.md) doc explains how to create a stack from scratch along with what is expected at each stage for it to be considered a stack.

## Repository Structure
Stacks are catagorised as either `experimental`, `incubator` or `stable` depending on the content of the stack.

`experimental/`: These stacks are labeled experimental as they may not fulfill the requirements of a appsody stack. Experimental stacks are also not expected to move out of this category into incubator or stable.

`incubator/`:

`stable/`:


Links on how can a user get started with creating a new stack

Quick explanation on various stability levels for stacks:

- experimental
- incubator
- stable
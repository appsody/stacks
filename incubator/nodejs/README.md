# Node.js Stack

A stack is the foundation of your application. This stack provides a prototype platform definition for Node.js v10 based projects.

## Templates

A template is your starting ppoint to begin developing your application.

### simple template

This is the simplest node.js application you can write.

## Getting Started

### Initializing the project

1. To start using this Node.js stack you can create a new folder in your local directory and initialize it using with the Appsody CLI eg:
```bash
mkdir my-project
cd my-project
appsody init nodejs
```
This command creates a new project based on the Node.js hello-world Template and then installs your development environment. This will also also install all your applications dependancies.

2. After your project has been intialized you can then run your application using the following command:
```bash
appsody run
```
This launches a Docker container that continuously re-builds and re-runs your project, exposing it on port 3000.

Note: you can continue to edit the application in VSCode IDE. Changes will be reflected in the running container around 2 seconds after the changes are saved.

## Limitations

what are the limitations??

# Pre-release

1. Cloning Appsody stacks repository
```bash
git clone https://github.com/appsody/stacks
```
2. Building the nodejs stack
```bash
cd into nodejs stack
docker build -t nodejs -f Dockerfile-stack .
```
3. Initializing your nodejs stack
```bash
cd template/helloworld
appsody init nodejs
```
4. Run your application
```bash
appsody run
```
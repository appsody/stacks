# Creating a Stack
The quickest way to get started creating a Appsody stack is to start from the sample provided in the stacks repository.

## Clone the sample
```
https://github.com/appsody/stacks

cd docs/sample-stack
```

## Stack
A stack is the foundation for your application. A stack can provide foundational capabilities that can be extended or replaced by the user application that is based on it. The stack has mechanisms to control which aspects can be overridden by a user-application and which aspects can not be overridden.

### Stack Structure
```
my-appsody-stack
├── README.md
├── LICENSE
├── stack.yaml
├── image
|   ├── project
|   |   └── Dockerfile
│   └── Dockerfile-stack
└── templates
    └── my-template
        └── .appsody-config.yaml
```

### Project directory:
The project folder should contain a Dockerfile for your application and the project you are going to provide as a content provider.

#### Dockerfile
Defines the final image that contains content from both the stack and template. This is used to run the application as a whole.

### Dockerfile-stack:
This Dockerfile defines the foundation application stack, and a set of envronment variables that specify the desired behaviour during local development cycle. It also defines what is exposed from the host machine to the container.
The environment variables that can be set to alter the behaviour of the cli and controller are described below:

| Variable                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        | Example                                                                                                   |
|--------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|

## Templates
A templates are pre-configured applications that are ready to use with a particular stack. It has access to all the dependencies supplied by that stack and is able to include extra dependencies plus new functionality to enhance the stack where allowed.

### .appsody-config.yaml
Here you can set what stack the template should point to. The following says that the template will use the nodejs-express image as its stack.
```
stack: nodejs-express:latest
```

## Further information

### Limitations:
**Note:** the cli requirements and stack structure are still in development and therefore currently have some limitations.


#### Stack images are not currently published offically:
Currently the stack images are not built and published so it is requires for the stack to be build locally before using a template.

``` bash
cd <stack-name>/stack
docker build -t <stack-name> -f Dockerfile-stack .
```

the `.appsody-config.yaml` should then point to this image.
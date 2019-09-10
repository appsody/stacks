# Kabanero Collections

Kabanero provides pre-configured collections that enable rapid development and deployment of quality microservice-based applications. Collections include an Appsody stack (base container image and project templates) and pipelines which act as a starting point for your application development.

**Appsody stacks:** Stacks include language runtimes, frameworks and any additional libraries and tools that are required to simplify your local application development. Stacks are an easy way to manage consistency and adopt best practices across many applications.
Click here to find out more about [Appsody stacks](https://github.com/appsody/website/blob/master/content/docs/stacks/stacks-overview.md).

**Template:** A template utilizes the base image and provides a starter application that is ready to use. It leverages existing capabilities provided by that image and can extend functionality to meet your application requirements.

**Pipeline:** A pipeline consists of k8s-style resources for declaring CI/CD-style pipelines (Tekton pipelines). 


---
Collections are categorized as either `stable`, `incubator` or `experimental` depending on the content of the collection.

- `stable/`: Stable collection meet this set of [technical requirements](https://github.com/appsody/stacks/blob/master/TECHNICAL_REQUIREMENTS.md).

- `incubator/`: The collection in the incubator folder are actively being worked on to satisfy the stable criteria.

- `experimental/`: Experimental collections are not being actively been worked on and may not fulfill the requirements of an Appsody stack. These can be used for trying out specific capabilities or proof of concept work.

**NOTE: Kabanero only builds and publishes collections that are categorized as 'incubator' or 'stable'**

## Kabanero Collections structure

This is a simplified view of the Kabanero Collections github repository structure.

```
ci
├── [ files used for CI/CD of the Kabanero collections ]
incubator
├── common/
|   ├── pipelines/
|   |   ├── common-pipeline-1/
|   |   |       └── [pipeline files that make up a full tekton pipeline used with all collections in incubator category]
|   |   └── common-pipeline-n/
|   |           └── [pipeline files that make up a full tekton pipeline used with all collections in incubator category]
├── collection-1/
|   ├── [collection files - see collection structure below]
├── collection-2/
|   └── [collection files - see collection structure below]
stable
├── common/
|   ├── pipelines/
|   |   ├── common-pipeline-1/
|   |   |       └── [pipeline files that make up a full tekton pipeline used with all collections in stable category]
|   |   └── common-pipeline-n/
|   |           └── [pipeline files that make up a full tekton pipeline used with all collections in stable category]
├── collection-1/
|   ├── [collection files - see collection structure below]
├── collection-n/
|   └── [collection files - see collection structure below]
experimental
├── common/
|   ├── pipelines/
|   |   ├── common-pipeline-1/
|   |   |       └── [pipeline files that make up a full tekton pipeline used with all collections in experimental category]
|   |   └── common-pipeline-n/
|   |           └── [pipeline files that make up a full tekton pipeline used with all collections in experimental category]
├── collection-1/
|   ├── [collection files - see collection structure below]
└── collection-n/
    └── [collection files - see collection structure below]
```

## Collection structure

There is a standard structure that all collections follow. The structure below represents the source structure of a collection:

```
my-collection
├── README.md
├── stack.yaml
├── collection.yaml
├── image/
|   ├── config/
|   |   └── app-deploy.yaml
|   ├── project/
|   |   ├── [files that provide the technology components of the stack]
|   |   └── Dockerfile
│   ├── Dockerfile-stack
|   └── LICENSE
├── pipelines/
|   ├── my-pipeline-1/
|   |       └── [pipeline files that make up the full tekton pipeline]
└── templates/
    ├── my-template-1/
    |       └── [example files as a starter for the application, e.g. "hello world"]
    └── my-template-2/
            └── [example files as a starter for a more complex application]

```

The structure above is then processed when you build the collection, to generate a Docker image for the stack, along with tar files of each of the templates and pipelines, which can then all be stored/referenced in a local or public appsody repo. Refer to the section on [Building and Testing Stacks](https://github.com/appsody/website/blob/master/content/docs/stacks/build-and-test.md) for more details. The appsody CLI can then access such a repo, to use the stack to initiate local development.

## Summary of files within the stack and collection source and user directory structure

### stack.yaml

The `stack.yaml` file in the top level directory defines the different attributes of the stack and which template the stack should use by default. See the example below:

```yaml
name: Sample Application Stack   # concise one line name for the stack
version: 0.1.0                   # version of the stack
description: sample stack to help creation of more appsody stacks # free form text explaining more about the capabilities of this stack and various templates
license: Apache-2.0              # license for the stack
language: nodejs                 # programming language the stack uses
maintainers:                     # list of maintainer(s) details
  - name: John Smith
    email: example@example.com
    github-id: jsmith
default-template: my-template-1  # name of default template
```

### Collection.yaml

The `collection.yaml` file in the top level directory defines the different attributes of the collection and which container image and pipeline the collection should use by default. See the example below:

```yaml
default-image: java-microprofile # name of the default container image - reference into the images element below
default-pipeline: default        # name of the default pipeline - reference to the pipeline in the directory structure
images:                          # list of container images
- id: java-microprofile
  image: $IMAGE_REGISTRY_ORG/java-microprofile:0.2
```

### README

The top level directory must contain a `README.md` markdown file that describes the contents of the collection and how it should be used.

### LICENSE

The `image` directory must contain a `LICENSE` file.

### app-deploy.yaml

The `app-deploy.yaml` is the configuration file for deploying an Appsody project using the Appsody Operator. For more information about specifics, see [Appsody Operator User Guide](https://github.com/appsody/appsody-operator/blob/master/doc/user-guide.md).

### Dockerfile-stack

The `Dockerfile-stack` file in the `image` directory defines the foundation stack image, and a set of environment variables that specify the desired behaviour during the rapid local development cycle. It also defines what is exposed from the host machine to the container during this mode.

Environment variables can be set to alter the behaviour of the CLI and controller (see [Appsody Environment Variables](https://github.com/appsody/website/blob/master/content/docs/stacks/environment-variables.md)).

### Dockerfile

The `Dockerfile` in the `image/project` directory defines the final image that will created by the `appsody build` command, which needs to contain the content from both the stack itself along with the user application (typically modified from one of the templates). This is used to run the application as a whole, outside of appsody CLI control.

### Templates

A template is a pre-configured starter application that is ready to use with the particular stack image. It has access to all the dependencies supplied by that image and is able to include new functionality and extra dependencies to enhance the image. A stack can have multiple templates, perhaps representing different classes of starter applications using the stack technology components.

### Pipelines

A pipeline is set of Tekton pipelines (k8s-style resources for declaring CI/CD-style pipelines) to use with the particular collection. A collection can have multiple pipelines.

### .appsody-config.yaml

The `.appsody-config.yaml` is not part of the source structure, but will be generated as part of the stack building process, and will be placed in the user directory by the `appsody init`, command. This file specifies the stack image that will be used, and can be overridden for testing purposes to a locally built stack.

For example, the following specifies that the template will use the python-flask image:

```yaml
stack: python-flask:0.1
```

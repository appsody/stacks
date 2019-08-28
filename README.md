![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

## Welcome to Kabanero!
<https://appsody.dev>

#### Create more, faster

Kabanero is an open source project focused on bringing together foundational open source technologies into 
a modern microservices-based framework. Developing apps for container platforms requires harmony between 
developers, architects, and operations. Today’s developers need to be efficient at much more than writing 
code. Architects and operations get overloaded with choices, standards, and compliance. Kabanero speeds 
development of applications built for Kubernetes while meeting the technology standards and policies your 
company defines. Design, develop, deploy, and manage with speed and control!

# Collections

This respository holds the default set of collections available from Kabanero. 
Each collection is pre-configured with popular open source technologies to enable rapid development 
and deployment of quality microservice-based applications. 
Collections include a base container image and project templates which act as a starting point for your 
application development as well as Tekton pipelines for deploying your microservice to Kubernetes.

To find out more about Kabanero check out [kabanero.io](https://kabanero.io).

## Repository Structure
The repository is based on the Appsody repository.
Click here to find out more about [Appsody stacks](https://github.com/appsody/website/blob/master/content/docs/stacks/stacks-overview.md).


## Building the collections (locally)

1. Clone the collections repository:
   ```
   bash
   git clone https://github.com/kabanero-io/collections.git
   cd collections
   ```

2. Create / Modify the collections (stacks) if required.
   Click here to find out more about [creating or modifying collections](https://github.com/appsody/website/blob/master/content/docs/stacks/create.md)

3. Setup environment
   There are several tools that are used to build
   ```
   yq - command-line YAML processor  (sudo snap install yq)
   python3
   pyyaml - YAML parser and emitter for python (pip3 install pyyaml)
   docker
   ```

   There are several environment variable that needs to be setup in order to correctly build the collections.
   ```
   # Docker credentials for publishing images:
   export DOCKER_USERNAME=<docker_username>
   export DOCKER_PASSWORD=<docker_password>
   export DOCKER_REGISTRY=<docker_registry>

   # Organization for Docker images
   export DOCKERHUB_ORG=<org_name>

4. Build collections
   From the base directory:

   Run build script and specify the desired stack as a parameter, for example:
   ```
   ./ci/build.sh
   ```
   
   Note that this will build all the collections in the incubator directory.
   
   The generated collection assests will be found in file://$PWD/ci/assets/ directory and all the  docker 
   images will have been created in your local docker registry.
   
5. Test the collections
   To test the collections you can add the kabanero-index.yaml to Appsody using the Appsody CLI 
   ```
   appsody repo add kabanero file://$PWD/ci/assets/kabanero-index-local.yaml
   ```

## Need help?
If you have a question that you can't find an answer to, we would also like to hear about that too. 
You can reach out to the community for assistance on [Slack]().

## Licence

Please see [LICENSE](https://github.com/kabanero-io/collections/blob/master/LICENSE) and [NOTICES](https://github.com/kabanero-io/collections/blob/master/NOTICE.md) for more information.

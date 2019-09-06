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

1. Clone the collections repository and create a new copy of it in your git organisation:
   ```
   bash
   git clone https://github.com/kabanero-io/collections.git
   git remote add private-org https://github.acme.com/my_org/collections.git
   git push -u private-org
   cd collections
   ```
   Once this has been done you will have your own copy of the collections repository in your own git org/repo.
   Follow any normal development processes you have for using git, ie creating branches etc.

2. Create / Modify the collections (stacks) if required.

   Click here to find out more about [creating or modifying collections](https://github.com/appsody/website/blob/master/content/docs/stacks/create.md)

3. Setup local build environment

   There are several tools that are used to build.
   ```
   * yq - command-line YAML processor  (sudo snap install yq)
   * docker
   ```
   These are only required if you are also building the Codewind Index (CODEWIND_INDEX=true)
   ```
   * python3
   * pyyaml - YAML parser and emitter for python (pip3 install pyyaml)
   ```

   There are several environment variable that needs to be setup. 
   These are required in order to correctly build the collections.
   ```
   # Organization for images
   # export IMAGE_REGISTRY_ORG=kabanero
   
   # Whether to build the Codewind Index file
   # CODEWIND_INDEX=false
   ```
   These are also required to correctly release the collections (if done manually)
   ```
   # Publish images to image registry
   # export IMAGE_REGISTRY_PUBLISH=false

   # Credentials for publishing images:
   # export IMAGE_REGISTRY=<registry>
   # export IMAGE_REGISTRY_USERNAME=<registry_username>
   # export IMAGE_REGISTRY_PASSWORD=<registry_password>
   ```

4. Build collections

   From the base directory, run the build script, for example:
   ```
   . ./ci/build.sh
   ```
   
   Note that this will build all the collections in the incubator directory.
   
   The generated collection assests will be found in file://$PWD/ci/assets/ directory and all the  docker 
   images will have been created in your local docker registry.
   
5. Test the collections

   To test the collections you can add the kabanero-index.yaml to Appsody using the Appsody CLI 
   ```
   appsody repo add kabanero file://$PWD/ci/assets/kabanero-index-local.yaml
   ```
   This will enable you to do an `appsody init` for a collection that is in the newly built kabanero collections. for example: `appsody init kabanero/java-microprofile`

6. Test the pipelines and other components that have been included in the collection within the Kabanero/OpenShift environment.
   ???
   
7. Once you have made all the changes to the collection and you are ready to push the changes back to your git repository then: 
    ```
    a) Commit your changes back to git.  e.g. `git commit -a -m "Updates to the collections"`
    b) Push the changes to your repository, e.g. `git push -u private-org`
    c) If `Travis CI` has been setup in your git organisation, see `Setting Up Travis CI`, then the push to git should trigger the Travis build to run which will ensure that the changes build OK.     ```
    
8. Release the final version of the collections

   Once all changes have been made to the Collections and they are ready to be released then:
   ```
    a) If a full release of the Collections is required then create a git tag and push the tags to git, ie `git tag "v0.1.1 -m "Collections v0.1.1"` and then `git push --tags`. 
    This will trigger another Travis build that will also generate a Git Release and push the Images to the image repository.
    ``` 
    
## Need help?
If you have a question that you can't find an answer to, we would also like to hear about that too. 
You can reach out to the community for assistance on [Slack]().

## Licence

Please see [LICENSE](https://github.com/kabanero-io/collections/blob/master/LICENSE) and [NOTICES](https://github.com/kabanero-io/collections/blob/master/NOTICE.md) for more information.

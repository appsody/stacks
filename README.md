![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

## Welcome to Kabanero Collections!
<https://kabanero.io>

# Collections

This repository holds the default set of collections available for Kabanero. Each collection is pre-configured with popular open-source technologies to enable rapid development and deployment of quality microservice-based applications. Collections include a base container image and project templates, which act as a starting point for your application development, as well as Tekton pipelines for deploying your microservice to Kubernetes.

To find out more about Kabanero, check out [kabanero.io](https://kabanero.io).

## Repository Structure
The repository is based on the Appsody repository.
Click here to find out more about [Appsody stacks](https://github.com/appsody/website/blob/master/content/docs/stacks/stacks-overview.md).


## Building the collections locally

1. Clone the collections repository and create a new copy of it in your git organization:
   ```bash
   git clone https://github.com/kabanero-io/collections.git
   git remote add private-org https://github.acme.com/my_org/collections.git
   git push -u private-org
   cd collections
   ```
   Once this has been done, you will have your own copy of the collections repository in your own git org/repo. Follow any normal development processes you have for using git (i.e., creating branches, etc.).

1. Create / Modify the collections (stacks) if required.

   Click here to find out more about [creating or modifying collections](https://github.com/appsody/website/blob/master/content/docs/stacks/create.md).

1. Set up local build environment

   There are several tools that are used to build.
     * yq
       * Command-line YAML processor  (sudo snap install yq)
     * docker
       * A tool to help you build and run apps within containers
   These are only required if you are also building the Codewind Index (CODEWIND_INDEX=true)
     * pyyaml
       * YAML parser and emitter for python (pip3 install pyyaml)

   There are several environment variables that need to be set up. These are required in order to correctly build the collections.
   ```bash
   # Organization for images
   export IMAGE_REGISTRY_ORG=kabanero

   # Whether to build the Codewind Index file
   CODEWIND_INDEX=false
   ```
   These settings are also required to correctly release the collections (if done manually):
   ```bash
   # Publish images to image registry
   export IMAGE_REGISTRY_PUBLISH=false

   # Credentials for publishing images:
   export IMAGE_REGISTRY=<registry>
   export IMAGE_REGISTRY_USERNAME=<registry_username>
   export IMAGE_REGISTRY_PASSWORD=<registry_password>
   ```

1. Build collections.

   From the base directory, run the build script.  For example:
    ```
    . ./ci/build.sh
    ```

   Note that this will build all the collections in the incubator directory.

   Following the build, you can find the generated collection assets in the file://$PWD/ci/assets/ directory and all the docker images in your local docker registry.

1. Test the collections.

   To test the collections, add the `kabanero-index.yaml` to Appsody using the Appsody CLI:

   ```bash
   appsody repo add kabanero file://$PWD/ci/assets/kabanero-index-local.yaml
   ```

   This will enable you to do an `appsody init` for a collection that is in the newly built kabanero collections.  For example:
   ```
   appsody init kabanero/java-microprofile
   ```

1. Test the pipelines and other components that have been included in the collection within the Kabanero/OpenShift environment.
   * More details coming.

1. Once you have made all the changes to the collection and you are ready to push the changes back to your git repository then:
    1. Commit your changes back to git.  For example:
    ```
    git commit -a -m "Updates to the collections"
    ```
    1. Push the changes to your repository.   For example:
    ```
    git push -u private-org
    ```
    1. If `Travis CI` has been setup in your git organization, the push to git should trigger the Travis build to run, which will ensure that the changes build OK. See `Setting Up Travis CI`.

1. Release the final version of the collections.

   Once all changes have been made to the Collections and they are ready to be released, if a full release of the collections is required, create a git tag:
   ```
   git tag "v0.1.1 -m "Collections v0.1.1"
   ```
   Then push the tags to git:
   ```
   git push --tags
   ```
   This will trigger another Travis build that will also generate a Git Release and push the images to the image repository.

## Need help?
If you have a question that you can't find an answer to, we would also like to hear about that too.
You can reach out to the community for assistance on the [Kabanero Slack channel](https://ibm-cloud-tech.slack.com/messages/CJZCYTD0Q).

## License

See [LICENSE](https://github.com/kabanero-io/collections/blob/master/LICENSE) and [NOTICES](https://github.com/kabanero-io/collections/blob/master/NOTICE.md) for more information.

![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

## Welcome to Kabanero Collections!
<https://kabanero.io>

# Collections

This repository holds the default set of collections available for Kabanero. Each collection is pre-configured with popular open-source technologies to enable rapid development and deployment of quality microservice-based applications. Collections include a base container image and project templates, which act as a starting point for your application development, as well as Tekton pipelines for deploying your microservice to Kubernetes.

To find out more about Kabanero, check out [kabanero.io](https://kabanero.io).

## Repository Structure
The repository is based on the Appsody repository structure with additional Kabanero Collections content. 

Click here to find out more about the [Repository structure](https://github.com/kabanero-io/collections/blob/master/repo-structure.md).

## Building the collections locally

1. Clone the collections repository and create a new copy of it in your git organization:
   ```bash
   git clone https://github.com/kabanero-io/collections.git
   cd collections
   git remote add private-org https://github.acme.com/my_org/collections.git
   git push -u private-org
   ```
   Once this has been done, you will have your own copy of the collections repository in your own git org/repo. Follow any normal development processes you have for using git (i.e., creating branches, etc.).

1. Create / Modify the collections if required.

   One of the main items in the collection that can be modified is the Appsody stack. Click here to find out more about [creating or modifying Appsody stacks](https://github.com/appsody/website/blob/master/content/docs/stacks/create.md).

1. Set up local build environment

   There are several tools that are used to build.
     * yq
       * Command-line YAML processor  (sudo snap install yq)
     * docker
       * A tool to help you build and run apps within containers
       
   These are only required if you are also building the Codewind Index (export CODEWIND_INDEX=true)
     * python3
       * Python is a general-purpose interpreted, interactive, object-oriented, and high-level programming language
     * pyyaml
       * YAML parser and emitter for python (pip3 install pyyaml)

   There are several environment variables that need to be set up. These are required in order to correctly build the collections.
   ```bash
   # Organization for images
   export IMAGE_REGISTRY_ORG=kabanero

   # Whether to build the Codewind Index file
   export CODEWIND_INDEX=false
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

## Testing the collections locally

1. Add the local collections repository to Appsody.

   The `./ci/build.sh` should have added the local kabanero index into the Appsody repository list. You can check this by running the command:
   ```
   appsody repo list
   ```
   
   The output from this command should include entries similar to:
   ``` 
   appsodyhub              https://github.com/appsody/stacks/releases/latest/download/incubator-index.yaml        
   kabanero-index          file:///Users/myuser/kabanero-io/collections/ci/assets/kabanero-index.yaml      
   kabanero-index-local    file:///Users/myuser/kabanero-io/collections/ci/assets/kabanero-index-local.yaml
   ```
   
   If the `kabanero-index-local` repository is not in the list then it can be added to Appsody using the Appsody CLI:

   ```bash
   appsody repo add kabanero-index-local file://$PWD/ci/assets/kabanero-index-local.yaml
   ```
   This will enable you to do an `appsody init` for a collection that is in the newly built kabanero collections.

1. Test the collections.

   To test the collections using the local docker images, rather than pulling them from docker hub, set the following environment variable:
   ```
   export APPSODY_PULL_POLICY=IFNOTPRESENT
   ```
   
   The `appsody init` will now use the local docker images. For example:
   ```
   appsody init kabanero-index-local/java-microprofile
   ```
   
   will create a new java-microprofile project using the local docker images and the local collection artifacts. 

1. Test the pipelines and other components that have been included in the collection within the Kabanero/OpenShift environment.

## [Optional] Test the collections using a test GIT release

Before creating a final production release for use with your Kabanero installation, you may wish to create a test release on a test GIT repository. 

1. Use these instructions to [create a GIT release manually](https://github.com/kabanero-io/collections/blob/master/create-release.md) from your local build.
1. Once all the artifacts are uploaded to the GIT Release, go to the assets inside that release and find the file kabanero-index.yaml and copy its URL.
e.g. https://github.com/kabanero-io/collections/releases/download/v0.2.0.beta2/kabanero-index.yaml
1. Within your Kabanero environment create a sample.yaml based on this sample yaml e.g.
https://raw.githubusercontent.com/kabanero-io/kabanero-operator/master/config/samples/full.yaml
1. In the yaml update the URL for the kabanero-index.yaml to tghe one from the release. e.g. 
https://github.com/kabanero-io/collections/releases/download/v0.2.0.beta2/kabanero-index.yaml
1. Save the yaml and then apply it to your Kabanero instance `kubectl apply -f sample.yaml`

This will update the collections and pipelines in your environment. New collections and pipeline should get activated as a result of this step.

## Releasing the collections

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

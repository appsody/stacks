![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

## Welcome to Kabanero Collections!
<https://kabanero.io>

# Collections

This repository holds the default set of collections available for Kabanero.
Each collection is pre-configured with popular open-source technologies to enable rapid development and deployment of quality microservice-based applications.
Collections include a base container image and project templates, which act as a starting point for your application development, as well as Tekton pipelines for deploying your microservice to Kubernetes.

To find out more about Kabanero, check out [kabanero.io](https://kabanero.io).

The [Working with Kabanero Collections](https://kabanero.io/guides/working-with-collections/) guide provides information on the following topics:

1. [Prerequisites](https://kabanero.io/guides/working-with-collections/#prerequisites)
1. [Getting started](https://kabanero.io/guides/working-with-collections/#getting-started)
1. [Creating a local Kabanero Collection hub](https://kabanero.io/guides/working-with-collections/#creating-a-local-kabanero-collection-hub)
1. [Understanding the file structure](https://kabanero.io/guides/working-with-collections/#understanding-the-file-structure)
1. [Modifying Collections](https://kabanero.io/guides/working-with-collections/#modifying-collections)
1. [Creating Collections](https://kabanero.io/guides/working-with-collections/#creating-collections)
1. [Deleting Collections](https://kabanero.io/guides/working-with-collections/#deleting-collections)
1. [Setting up a local build environment](https://kabanero.io/guides/working-with-collections/#setting-up-a-local-build-environment)
1. [Building Collections](https://kabanero.io/guides/working-with-collections/#building-collections)
1. [Testing a Collection locally](https://kabanero.io/guides/working-with-collections/#testing-a-collection-locally)
1. [Releasing Collections](https://kabanero.io/guides/working-with-collections/#releasing-collections)

## How to test prior to a release
In addition to the "Working with Kabanero Collections guide" the following section provides information about *Testing prior to creating a production release*

Before creating a final production release for use with your Kabanero installation, you may wish to create a test release on a test GIT repository.

1. Use these instructions to [create a GIT release manually](https://github.com/kabanero-io/collections/blob/master/create-release.md) from your local build.
1. Once all the artifacts are uploaded to the GIT Release, go to the assets inside that release and find the file kabanero-index.yaml and copy its URL.
e.g. https://github.com/kabanero-io/collections/releases/download/v0.2.0.beta2/kabanero-index.yaml
1. Within your Kabanero environment create a sample.yaml based on this sample yaml e.g.
https://raw.githubusercontent.com/kabanero-io/kabanero-operator/master/config/samples/full.yaml
1. In the yaml update the URL for the kabanero-index.yaml to the one from the release. e.g.
https://github.com/kabanero-io/collections/releases/download/v0.2.0.beta2/kabanero-index.yaml
1. Save the yaml and then apply it to your Kabanero instance `kubectl apply -f sample.yaml`

This will update the collections and pipelines in your environment. New collections and pipeline should get activated as a result of this step.

1. [Optional] Publish built images to an image registry

   If building locally you may want to publish the built images to an image registry. If using Travis to build your release then these should be pushed as part of the Travis build.

   In order to push these images correctly there are some environment variables that will need to be setup:
   ```bash
   # Publish images to image registry
   export IMAGE_REGISTRY_PUBLISH=true

   # Credentials for publishing images:
   export IMAGE_REGISTRY=<registry>
   export IMAGE_REGISTRY_USERNAME=<registry_username>
   export IMAGE_REGISTRY_PASSWORD=<registry_password>
   ```
   Once these environment variable have been set you can publish the images by running a script.
   From the base directory, run the release script.  For example:
    ```
    . ./ci/release.sh
    ```
   This will copy files from the ./ci/assets directory to a ./ci/release directory and will then push the built images to the specified image registry.

1. [Optional] Create a production Git Release

   If building locally and not using Travis, you will need to create a release on a production GIT repository.

   1. Use these instructions to [create a GIT release manually](https://github.com/kabanero-io/collections/blob/master/create-release.md) using the files in the ./ci/release directory rather than the ./ci/assets directory.
   1. Once all the artifacts are uploaded to the GIT Release, go to the assets inside that release and find the file kabanero-index.yaml and copy its URL for use within your Kabanero instance.
   ```
     e.g. https://github.com/kabanero-io/collections/releases/download/v0.2.0.beta2/kabanero-index.yaml .
   ```

## Github Enterprise considerations

When using Github Enterprise to store collections you may need an alternative mechanism for hosting your release artifacts due to authentication requirements. See [Hosting your collections using NGINX](https://github.com/kabanero-io/collections/blob/master/ci/tekton/README.md), which describes the steps needed to build your collections and deploy an NGINX server to host them into your Kabanero instance.

## Need help?
If you have a question that you can't find an answer to, we would also like to hear about that too.
You can reach out to the community for assistance on the [Kabanero Slack channel](https://ibm-cloud-tech.slack.com/messages/CJZCYTD0Q).

## License

See [LICENSE](https://github.com/kabanero-io/collections/blob/master/LICENSE) and [NOTICES](https://github.com/kabanero-io/collections/blob/master/NOTICE.md) for more information.

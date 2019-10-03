# Create GIT release manually

To create a GIT Release from a local build, the build will need to be created as if it were a production release and the artifacts generated as if the automated build system (ie Travis) had built them. 
This will require a few extra environment variables to be setup for the build. These are:

```
TRAVIS_REPO_SLUG=kabanero-io/collections  # The git organisation and repository in which the release will be created. 
IMAGE_REGISTRY_ORG=kabanero               # The image organisation to which the images will be published.
TRAVIS_TAG=v0.2.0                         # The tag name for git release that the artificats will be published.
```

Once these additional environment variables are setup then run `./ci/build.sh` from the base directory of your git project on your local machine, ie <some_path>/collections

Once the build has completed, the ./ci/assets directory will contain the generated assets.
These are the assets that need to be uploaded to the git release.

To create the git release and upload the artifacts follow these steps:

1. Go to the releases section of your github repository, i.e. https://github.com/<TRAVIS_REPO_SLUG>/releases
1. Click the `Draft a new release` button
1. Enter the tag name to be used. This needs to be the same as the TRAVIS_TAG environment variable.
1. Enter the release title
1. Drag and drop the newly built assets (from ./ci/assets) onto the box at the bottom of the page.
1. When all the assets are uploaded click `Publish Release`.
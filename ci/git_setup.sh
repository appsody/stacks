if [ -n "$TRAVIS_TAG" ]
then
  if [ -n "$RELEASE_BRANCH" ]
  then
    echo "Release branch is: $RELEASE_BRANCH"
    TRAVIS_BRANCH=${RELEASE_BRANCH}
  else
    echo "No RELEASE_BRANCH environment variable set: defaulting to master"
    TRAVIS_BRANCH="master"
  fi

  git clone --depth=50 --branch=$TRAVIS_BRANCH https://github.com/$TRAVIS_REPO_SLUG.git $TRAVIS_BUILD_DIR/release
  cd $TRAVIS_BUILD_DIR/release

  echo "Looking for release commit in branch..."
  git branch --contains $TRAVIS_COMMIT
  git status

  if [[ $(echo $?) != "0" ]]
  then
    echo "Error: could not find release commit in release branch! Branch: $TRAVIS_BRANCH , Commit: $TRAVIS_COMMIT"
    exit 1
  fi

  echo "Reseting branch to release commit: $TRAVIS_COMMIT"
  git reset --hard $TRAVIS_COMMIT
  git status
fi



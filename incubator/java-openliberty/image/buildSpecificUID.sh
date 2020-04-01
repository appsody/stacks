#!/bin/bash

#################################################
# Create development environment for specific UID
# and GID
# Command format:
# buildSpecificUID.sh UID GID
################################################

if [[ $# -eq 2 ]]; then
  if [[ ! -f "Dockerfile-stack.default" ]]; then
    mv Dockerfile-stack Dockerfile-stack.default
    sed "s/<GID>/$2/;s/<UID>/$1/" Dockerfile-stack-defined-user.template > Dockerfile-stack
  else
    echo "buildSpecificUID.sh has been run previously. Please backup Dockerfile-stack.default before continuing" 
  fi
else
  echo "invalid command format"
  echo "command format is buildSpecificUID.sh UID GID"
fi

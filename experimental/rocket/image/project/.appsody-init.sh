#!/bin/bash
#
# Create local copy of package dependencies to enable building while developing locally.
#
set -e

# Current directory is .appsody-init, which is a child of the user's
# project directory, so we copy the dependencies to a .appsody directory
# one level up.
ls && cp -R -p ./deps ../.appsody

# Mark dependency source code as read-only
find ../.appsody -type f -name '*.rs' -exec chmod ugo-w {} \;
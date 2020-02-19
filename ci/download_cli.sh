#!/bin/bash
# invoked from .travis.yml

if [ -z "${APPSODY_CLI_RELEASE_URL}" ]
then
    APPSODY_CLI_RELEASE_URL=https://api.github.com/repos/appsody/appsody/releases/latest
fi
if [ -z "${APPSODY_CLI_DOWNLOAD_URL}" ]
then
    APPSODY_CLI_DOWNLOAD_URL=https://github.com/appsody/appsody/releases/download
fi
if [ -z "${APPSODY_CLI_FALLBACK}" ]
then
    APPSODY_CLI_FALLBACK=0.5.8
fi

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
base_dir=$(cd "${script_dir}/.." && pwd)

cli_dir=$base_dir/cli
mkdir -p $cli_dir

curl -L -s -o $cli_dir/release.json "$APPSODY_CLI_RELEASE_URL"
release_tag=$(cat $cli_dir/release.json | grep "tag_name" | cut -d'"' -f4)
if ! [[ "$release_tag" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
then
    echo "Falling back to ${APPSODY_CLI_FALLBACK}"
    cat $cli_dir/release.json
    release_tag=${APPSODY_CLI_FALLBACK}
fi

# force to be a specific fallback version
if [ ! -z $FORCE_APPSODY_CLI_FALLBACK ]
then
    release_tag=$FORCE_APPSODY_CLI_FALLBACK
fi

cli_file="appsody-${release_tag}-linux-amd64.tar.gz"
cli_dist=$APPSODY_CLI_DOWNLOAD_URL/${release_tag}/${cli_file}

echo " release_tag=${release_tag}"
echo " cli_file=${cli_file}"
echo " cli_dist=${cli_dist}"

curl -L -s -o "$cli_dir/$cli_file" "$cli_dist"
sudo tar xvf "$cli_dir/$cli_file" -C  /usr/local/bin/ appsody
sudo chmod +x /usr/local/bin/appsody


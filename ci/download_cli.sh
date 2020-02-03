#!/bin/bash
# invoked from .travis.yml

if [ "$TRAVIS" == "true" ]
then
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
        APPSODY_CLI_FALLBACK=0.5.4
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

    cli_deb="appsody_${release_tag}_amd64.deb"
    cli_dist=${APPSODY_CLI_DOWNLOAD_URL}/${release_tag}/${cli_deb}

    echo " release_tag=${release_tag}"
    echo " cli_deb=${cli_deb}"
    echo " cli_dist=${cli_dist}"

    curl -L -s -o "$cli_dir/$cli_deb" "$cli_dist"
    sudo dpkg -i $cli_dir/$cli_deb
fi
#!/bin/bash

set -Eeo pipefail

usage () {
    echo "Usage: $0 -s SRC_PATH -d DEST_URL [-u REPO_USERNAME -p REPO_PASSWORD -t TARGET_PATH -h]"
}

while getopts ":s:d:t:u:p:h" opt; do
    case ${opt} in
        s )
            SRC_PATH=$OPTARG
            ;;
        d )
            DEST_URL=$OPTARG
            ;;
        u )
            REPO_USERNAME=$OPTARG
            ;;
        p )
            REPO_PASSWORD=$OPTARG
            ;;
        t )
            TARGET_PATH=$OPTARG
            ;;
        h )
            usage
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            usgae
            exit 1
            ;;
        : )
            echo "Invalid Option: -$OPTARG requires an argument" 1>&2
            usage
            exit 1
            ;;
    esac
done

if [ -z "$SRC_PATH" ]; then
    echo "ERROR: Must specify collection source path using the '-s' option"
    usage
    exit 1
fi

if [ -z "$DEST_URL" ]; then
    echo "ERROR: Must specify collection destination URL using the '-d' option"
    usage
    exit 1
fi

if [ -z "$REPO_USERNAME" ]; then
    echo "ERROR: Must specify destination repository username either by using option '-u' or by setting the 'REPO_USERNAME' environment variable"
    usage
    exit 1
fi

if [ -z "$REPO_PASSWORD" ]; then
    echo "ERROR: Must specify destination repository password either by using option '-p' or by setting the 'REPO_PASSWORD' environment variable"
    usage
    exit 1
fi

echo -e "The following will be uploaded to ${DEST_URL}/${TARGET_PATH}:\n"

FILES_TO_UPLOAD=$(find $SRC_PATH -type f)

for file in $FILES_TO_UPLOAD
do
    echo "$file"
done

read -p "Do you wish to continue? (y/N)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo 'uploading...'
    for item in $FILES_TO_UPLOAD
    do
        HTTP_CODE=$(curl -o /dev/null -w "%{http_code}" -s -u "${REPO_USERNAME}:${REPO_PASSWORD}" -X PUT ${DEST_URL}/${TARGET_PATH}/$(basename ${item}) -T ${item})
        if [ $HTTP_CODE -ne 201 ]; then
            echo "WARN: ${item} was not uploaded properly. HTTP_CODE: ${HTTP_CODE}"
        else
            echo "INFO: ${item} uploaded"
        fi
    done
else
    echo 'Aborting upload'
fi

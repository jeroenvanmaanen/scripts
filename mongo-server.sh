#!/bin/bash

set -e

VOLUME="$1"
if [ -z "${VOLUME}" ]
then
    echo "Usage $(basename "$0") <volume-name>" >&2
    exit 1
fi

CONTAINER="mongodb-${VOLUME}"

docker run \
    -d \
    --mount "type=volume,src=${VOLUME},dst=/data/db" \
    -p 27017:27017 \
    -p 28017:28017 \
    --name "${CONTAINER}" \
    mongo \
    mongod --rest --httpinterface
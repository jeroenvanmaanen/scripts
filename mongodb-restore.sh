#!/usr/bin/env bash

MONGO_CONTAINER="$1" ; shift
SRC_DIR="$1" ; shift

if [[ ! -d "${SRC_DIR}" ]]
then
    echo "Usage: $(basename "$0") <mongo-container> <source-directory>" >&2
    exit 1
fi

(
    docker run --rm --link "${MONGO_CONTAINER}:mongo" -v "${SRC_DIR}:${SRC_DIR}" -w "${SRC_DIR}" mongo:3.4 \
        /bin/bash -c 'mongorestore --host mongo --gzip .'
)

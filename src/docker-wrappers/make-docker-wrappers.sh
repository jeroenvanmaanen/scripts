#!/bin/bash

set -e -x

BIN="$(cd "$(dirname "$0")" ; pwd)"

(
    cd "${BIN}"
    for IMAGE_NAME in *
    do
        if [ -f "${IMAGE_NAME}/Dockerfile" ]
        then
            "${BIN}/make-docker-wrapper.sh" "${IMAGE_NAME}"
        fi
    done
)

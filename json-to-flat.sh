#!/bin/bash

set -e

DIR="$(pwd)"

docker run --rm -v "${DIR}:${DIR}" -w "$DIR" -i jeroenvm/jsontoflat:0.1-SNAPSHOT "$@"

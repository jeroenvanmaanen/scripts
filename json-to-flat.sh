#!/bin/bash

DIR="$(pwd)"

docker run --rm -v "${DIR}:${DIR}" -w "$DIR" jeroenvm/jsontoflat:0.1-SNAPSHOT "$@"

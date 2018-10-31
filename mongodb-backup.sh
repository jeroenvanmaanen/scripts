#!/usr/bin/env bash

MONGO_CONTAINER="$1" ; shift

docker run --rm --link "${MONGO_CONTAINER}:mongo" -v "${PWD}:${PWD}" -w "${PWD}" mongo:3.4 /bin/bash -c 'mongodump --host mongo --gzip --out "$(date +%FT%T | tr : .)"'

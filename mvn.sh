#!/bin/bash

DIR="$(pwd)"

docker run --rm -v "${DIR}:${DIR}" -w "${DIR}" "maven:3-jdk-8-alpine" mvn "$@"

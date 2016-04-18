#!/bin/bash

set -e -x

IMAGE_NAME="$1"
shift

BIN="$(cd "$(dirname "$0")" ; pwd)"

docker build "$@" -t jeroenvm/wrapper-"${IMAGE_NAME}" "${BIN}/${IMAGE_NAME}"
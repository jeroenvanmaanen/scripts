#!/bin/bash

mkdir -p "${HOME}/.aws"

CWD="$(pwd)"

docker run --rm -ti -v "${HOME}/.aws:/home/aws/.aws" -v "${CWD}:${CWD}" -w "${CWD}" 'fstab/aws-cli' /home/aws/aws/env/bin/aws "$@"

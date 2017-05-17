#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

export SLS_IGNORE_WARNING='*'

if [ ".$1" = ".-v" ]
then
    SLS_IGNORE_WARNING=''
    shift
    set -x
fi

if [ ".$1" = '.--source' ]
then
    . "$2"
    shift
    shift
fi

if [ ".$1" = '.--' ]
then
    shift
fi

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

"${BIN}/run-docker-wrapped-command.sh" \
    -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
    -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
    -e "SLS_IGNORE_WARNING=${SLS_IGNORE_WARNING}" \
    serverless \
    /usr/bin/serverless "$@"

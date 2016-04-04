#!/bin/bash

NAME='dind'
if [ -n "$1" ]
then
    NAME="$1"
    shift
fi

docker run --privileged --name "${NAME}" -v /Users:/Users -d docker:dind

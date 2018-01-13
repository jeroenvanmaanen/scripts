#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

CURRENT="$(pwd)"

if [ ".$1" = '.-h' -o ".$1" = '--help' ]
then
    echo "Usage: $(basename "$0") [ <jre-arg> ]... [ -- [ <docker-arg> ]... ]" 2>&1
    exit 0
fi

declare -a JRE_FLAGS
JRE_FLAGS=()
while [ "$#" -gt 0 -a ".$1" != '.--' ]
do
    JRE_FLAGS[${#JRE_FLAGS[@]}]="$1"
    shift
done
if [ ".$1" = '.--' ]
then
    shift
fi

docker run -v "${CURRENT}:${CURRENT}" -w "${CURRENT}" "$@" openjdk:8-jre-alpine java "${JRE_FLAGS[@]}"

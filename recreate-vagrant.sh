#!/bin/bash

set -e

function usage() {
    echo "Usage: $(basename "$0") [ --all ] [ -- ] <box-name> ..." >&2
}

ALL='false'
if [ ".$1" = ".--all" ]
then
    ALL='true'
    shift
fi

if [ ".$1" = '.--' ]
then
    shift
fi

if [ "$#" -lt 1 ]
then
    if "${ALL}"
    then
        :
    else
        usage
        exit
    fi
fi

( vagrant destroy -f "$@" && vagrant up "$@" ) 2>&1 | tee ~/tmp/recreate-vagrant.log | color-code.sh
RC="$?"
echo "RC=${RC}" >&2
exit "$RC"

#!/bin/bash

SILENT='true'
if [ ".$1" = '.-v' ]
then
    shift
    SILENT='false'
fi

TRACE='false'
if [ ".$1" = '.-v' ]
then
    shift
    TRACE='true'
    set -x
fi

BIN="$(cd "$(dirname "$0")" ; pwd)"

IMAGES_FLAGS=()
if [ ".$1" = '.-a' ]
then
    shift
    IMAGES_FLAGS[${#IMAGES_FLAGS[@]}]='--all'
fi

function log() {
    "${SILENT}" || echo ">>> $*" >&2
}

function log-var() {
    local VAR="$1"
    if "${SILENT}"
    then
        :
    else
        log "VAR=$(eval "echo \"\$${VAR}\"")"
    fi
}

log "Removing exited containers"
EXITED_CONTAINERS="$("${BIN}/docker-ps.sh" --all | grep '^[0-9a-f]*[.]Status: Exited' | sed -e 's/[.].*//')"
if [ -n "${EXITED_CONTAINERS}" ]
then
    docker rm ${EXITED_CONTAINERS}
fi

log "Removing unidentified images"
UNIDENTIFIED_IMAGES="$("${BIN}/docker-cli.py" -k Id images "${IMAGES_FLAGS[@]}" | sed -n -e '/[.]RepoTags\[1\]: <none>:<none>/!b next' -e 's/^@//' -e 's/[.].*//' -e p -e :next)"
if [ -n "${UNIDENTIFIED_IMAGES}" ]
then
    docker rmi ${UNIDENTIFIED_IMAGES}
fi

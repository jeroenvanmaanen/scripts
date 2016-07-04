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
else
    exec 2>/dev/null
fi

BIN="$(cd "$(dirname "$0")" ; pwd)"

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

STATUS="$(docker-machine status)"
log-var STATUS
if [ ".${STATUS}" = ".Stopped" -o ".${STATUS}" = ".Aborted" ]
then
    mkdir -p ~/.docker-machine
    if "${BIN}/create-lock-file.sh" ~/.docker-machine/pid
    then
        log "Start docker-machine"
        docker-machine start >&2
        rm ~/.docker-machine/pid
    else
        log "Wait for docker-machine"
        S=40
        echo -n . >&2
        while [ $S -gt 0 ]
        do
            STATUS="$(docker-machine status)"
            if [ ".${STATUS}" = ".Running" ]
            then
                break
            fi
            S=$[S-1]
            sleep 1
            echo -n . >&2
        done
        echo >&2
    fi
fi

STATUS="$(docker-machine status)"
echo "docker-machine ${STATUS}" >&2
if [ ".${STATUS}" = ".Running" ]
then
    docker-machine env 2>/dev/null
fi

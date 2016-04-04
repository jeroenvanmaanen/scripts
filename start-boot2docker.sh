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

STATUS="$(boot2docker status)"
log-var STATUS
if [ ".${STATUS}" = ".poweroff" -o ".${STATUS}" = ".aborted" ]
then
    mkdir -p ~/.boot2docker
    if "${BIN}/create-lock-file.sh" ~/.boot2docker/pid
    then
        log "Start boot2docker"
        boot2docker start >&2
        rm ~/.boot2docker/pid
    else
        log "Wait for boot2docker"
        S=40
        echo -n . >&2
        while [ $S -gt 0 ]
        do
            STATUS="$(boot2docker status)"
            if [ ".${STATUS}" = ".running" ]
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

STATUS="$(boot2docker status)"
echo "boot2docker ${STATUS}" >&2
if [ ".${STATUS}" = ".running" ]
then
    boot2docker shellinit 2>/dev/null
fi

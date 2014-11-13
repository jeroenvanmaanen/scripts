#!/usr/bin/false
# This is a libary and cannot be run from the command line

function debug() {
    if "${SILENT}"
    then
        return 0
    fi

    local LABEL="$1"
    local FIRST="[DEBUG] "
    local FOLLOW="$(echo "${FIRST}" | tr '' '.')"
    shift
    if [ "$#" -lt 1 ]
    then
        set ''
    fi

    local PREFIX="${FIRST}"
    for A in "$@"
    do
        if [ -z "${A}" ]
        then
            echo "[DEBUG] ${LABEL}" >&2
        else
            echo "[DEBUG] ${LABEL}: [${A}]" >&2
        fi
        PREFIX="${FOLLOW}"
    done
}

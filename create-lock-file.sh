#!/bin/bash

TRACE='false'
if [ ".$1" = '.-v' ]
then
    shift
    TRACE='true'
    set -x
else
    exec 2>/dev/null
fi

set -C -e -x

FILE_NAME="$1"
PID="$(cat "${FILE_NAME}" || true)"
if [ -n "${PID}" ]
then
    if kill -0 "${PID}"
    then
        :
    else
        "${0}" "${FILE_NAME}.2" && rm "${FILE_NAME}" "${FILE_NAME}.2"
    fi
fi
trap 'exit 1' INT TERM EXIT
echo "${PPID}" > "${FILE_NAME}"
trap '' INT TERM EXIT
exit 0

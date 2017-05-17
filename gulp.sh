#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

IMAGE='nodejs'
if [ ".$(basename "$0" .sh)" = '.gulp4.sh' ]
then
    IMAGE='nodejs4'
fi

function log() {
    local LEVEL="$1"
    shift
    echo "[$LEVEL] $*" >&2
}
function error() {
    log ERROR "$@"
    exit 1
}

GULP_FILE='gulpfile.js'
if [ ! -e "${GULP_FILE}" ]
then
    error Missing "$GULP_FILE"
fi

GULP='node_modules/gulp/bin/gulp.js'
if [ ! -x "${GULP}" ]
then
    error Missing gulp package
fi

"${BIN}/run-docker-wrapped-command.sh" "${IMAGE}" "${GULP}" "$@"

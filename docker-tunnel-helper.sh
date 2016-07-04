#!/bin/bash

set -ex

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/update-settings.sh"

SERVER="$1"
shift

NAME="$1"
shift

HOST_SETTINGS="$(echo ~/.tunnel/"${SERVER}".sh)"
update-settings "${HOST_SETTINGS}"

END_POINT_SETTINGS="$(echo ~/.tunnel/"${NAME}".sh)"
update-settings "${END_POINT_SETTINGS}"

source "${HOST_SETTINGS}"
source "${END_POINT_SETTINGS}"

ID_FILE=''
USER=''
HOST='localhost'
PORT=''

END_POINT_CONTAINER=''
END_POINT_PORT=''

if [ -e "${HOST_SETTINGS}" ]
then
    source "${HOST_SETTINGS}"
fi

if [ -e "${END_POINT_SETTINGS}" ]
then
    source "${END_POINT_SETTINGS}"
fi

declare -a ARGUMENTS

function add-argument() {
    ARGUMENTS[${#ARGUMENTS[@]}]="$1"
}

function add-arguments() {
    for ITEM in "$@"
    do
        add-argument "${ITEM}"
    done
}

function get-var() {
    local NAME="$1"
    eval "echo \${${NAME}}"
}

TARGET="${HOST}"
if [ -n "${USER}" ]
then
    TARGET="${USER}@${TARGET}"
fi

if [ -n "${ID_FILE}" ]
then
    add-arguments -i "$(echo ${ID_FILE} | sed -e "s;^~;${HOME};")"
fi

if [ -n "${PORT}" ]
then
    add-arguments -p "${PORT}"
fi
add-argument "${TARGET}"

INSPECT_FORMAT="--format='{{.NetworkSettings.IPAddress}}:{{(index (index .NetworkSettings.Ports \"${END_POINT_THAT_PORT}/tcp\") 0).HostPort}}'"

FORWARD="$(ssh "${ARGUMENTS[@]}" docker inspect "${INSPECT_FORMAT}" "${END_POINT_CONTAINER}")"

set -x
ssh -L "${END_POINT_THIS_PORT}:${FORWARD}" -N -n "${ARGUMENTS[@]}"
#!/bin/bash

set -e

echo "$(basename "$0") $*"

BIN="$(cd "$(dirname "$0")" ; pwd)"

DIR=''
if [ ".$1" = '.--dir' ]
then
    shift
    DIR="$1"
    shift
fi
if [ -z "${DIR}" ]
then
    DIR="$(echo ~/.tunnel)"
fi

NAME="$1"
shift

SETTINGS="${DIR}/${NAME}.sh"

ID_FILE=''
ID_PATH=''
USER=''
HOST='localhost'
PORT=''
FORWARD_SIZE='0'

if [ -e "${SETTINGS}" ]
then
    source "${SETTINGS}"
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

INDEX=0
while [ "${INDEX}" -lt "${FORWARD_SIZE}" ]
do
    DIRECTION="$(get-var "FORWARD_${INDEX}_DIRECTION")"
    BIND_IP="$(get-var "FORWARD_${INDEX}_BIND_IP")"
    THIS_PORT="$(get-var "FORWARD_${INDEX}_THIS_PORT")"
    THAT_PORT="$(get-var "FORWARD_${INDEX}_THAT_PORT")"
    FORWARD_FLAG='-?'
    FORWARD_HOST=''
    case "${DIRECTION}" in
    out*)
        FORWARD_FLAG=-L
        FORWARD_HOST="$(get-var "FORWARD_${INDEX}_THAT_HOST")"
        ;;
    in*)
        FORWARD_FLAG=-R
        FORWARD_HOST="$(get-var "FORWARD_${INDEX}_THIS_HOST")"
        ;;
    *)
    esac
    FORWARD_SPECIFICATION="${THIS_PORT}:${FORWARD_HOST}:${THAT_PORT}"
    if [ -n "${BIND_IP}" ]
    then
        FORWARD_SPECIFICATION="${BIND_IP}:${FORWARD_SPECIFICATION}"
    fi
    add-arguments "${FORWARD_FLAG}" "${FORWARD_SPECIFICATION}"
    INDEX=$[${INDEX}+1]
done

add-arguments -N -n

if [ -n "${ID_FILE}" ]
then
    ID_PATH="$(echo ${ID_FILE} | sed -e "s;^~;${HOME};")"
    echo ">>> ID_PATH: [${ID_PATH}]"
    add-arguments -i "${ID_PATH}"
fi

if [ -n "${PORT}" ]
then
    add-arguments -p "${PORT}"
fi
add-argument "${TARGET}"

echo
echo '>>> ssh'
for ITEM in "${ARGUMENTS[@]}"
do
    echo ">>> [${ITEM}]"
done

set -x
ssh "${ARGUMENTS[@]}"

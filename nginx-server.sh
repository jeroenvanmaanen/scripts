#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

function usage() {
    echo "Usage: $(basename "$0") [ -d <package-dir> | -w <web-root-dir> ] [ -p <port> ] [ -n <name> ] [ -- <docker-options> ]" >&2
    exit 1
}

CONTAINER='nginx'
CONFIG_DIR=''
WEB_ROOT_DIR="$(pwd)"
PORT='8888'
while [ ".${1#-}" != ".$1" ]
do
    OPT="$1"
    shift
    if [ ".${OPT}" = '.--' ]
    then
        break
    fi
    case "${OPT}" in
    -n|--name)
        CONTAINER="nginx-$1"
        shift
        ;;
    -d|--package-dir)
        CONFIG_DIR="$1/etc"
        WEB_ROOT_DIR="$1/web"
        shift
        ;;
    -w|--web-dir)
        WEB_ROOT_DIR="$1"
        shift
        ;;
    -p)
        PORT="$1"
        shift
        ;;
    *)
        usage
    esac
done

declare -a EXTRA_OPTS
EXTRA_OPTS=()
if [ -n "${CONFIG_DIR}" ]
then
    EXTRA_OPTS=(--mount "type=bind,src=${CONFIG_DIR},dst=/etc/nginx")
fi
EXTRA_OPTS=("${EXTRA_OPTS[@]}" "$@")

docker run \
    -d \
    --mount "type=bind,src=${WEB_ROOT_DIR},dst=/usr/share/nginx/html" \
    -p "${PORT}:80" \
    "${EXTRA_OPTS[@]}" \
    --name "${CONTAINER}" \
    nginx
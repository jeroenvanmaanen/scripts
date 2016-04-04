#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

set -e

REPO='jeroenvm'
TAG='latest'

declare -a DOCKER_ARGS
while [ ".$(expr "$1" : '^\(-\).*$')" = '.-' ]
do
    OPT="$1"
    shift
    if [ ".${OPT}" = '.--' ]
    then
        break
    fi
    DOCKER_ARGS[${#DOCKER_ARGS[@]}]="${OPT}"
    case "${OPT}" in
    -e|-v)
        DOCKER_ARGS[${#DOCKER_ARGS[@]}]="$1"
        shift
        ;;
    *)
    esac
done

IMAGE="wrapper-$1"
shift

DIR="$(pwd)"

docker run --rm -ti -v "${DIR}:${DIR}" -v "${BIN}:${BIN}" -w "${DIR}" "${DOCKER_ARGS[@]}" "${REPO}/${IMAGE}:${TAG}" "$@"

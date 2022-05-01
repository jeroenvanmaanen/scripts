#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

# Refactor this to use lib-docker-wrapper.sh (or, even better, refactor the scripts that call this).

set -e

REPO='jeroenvm'
TAG='latest'

RM='--rm'

declare -a DOCKER_ARGS
while [ ".$(expr "$1" : '^\(-\).*$')" = '.-' ]
do
    OPT="$1"
    shift
    if [ ".${OPT}" = '.--' ]
    then
        break
    fi
    if [ ".${OPT}" = ".--keep" ]
    then
        RM=''
    elif [ ".${OPT}" = ".--verbose" ]
    then
        set -x
    else
        DOCKER_ARGS[${#DOCKER_ARGS[@]}]="${OPT}"
        case "${OPT}" in
        -e|-v|--link|--expose|--name|--net|-p)
            DOCKER_ARGS[${#DOCKER_ARGS[@]}]="$1"
            shift
            ;;
        *)
        esac
    fi
done

IMAGE="wrapper-$1"
shift

DIR="$(pwd)"

docker run ${RM} -v "${DIR}:${DIR}" -v "${BIN}:${BIN}" -w "${DIR}" "${DOCKER_ARGS[@]}" "${REPO}/${IMAGE}:${TAG}" "$@"

#!/bin/bash

function run-docker-wrapped-command() {
    local REPO='jeroenvm'
    local TAG='latest'
    local RM='--rm'
    local IMAGE=''
    local WORK_DIR="$(pwd)"
    local MOUNT_DIR="${WORK_DIR}"

    declare -a DOCKER_ARGS
    DOCKER_ARGS=()
    while [ ".$(expr "$1" : '^\(-\).*$')" = '.-' ]
    do
        OPT="$1"
        shift
        if [ ".${OPT}" = '.--' ]
        then
            break
        fi

        case "${OPT}" in
        --keep|-k)
            RM=''
            ;;
        --verbose)
            set -x
            ;;
        --work-dir|-w)
            WORK_DIR="$1" ; shift
            MOUNT_DIR="${WORK_DIR}"
            ;;
        --mount-dir|-m)
            MOUNT_DIR="$1" ; shift
            ;;
        *)
            DOCKER_ARGS[${#DOCKER_ARGS[@]}]="${OPT}"
            case "${OPT}" in
            -e|-v|--link|--expose|--name|--net|-p)
                DOCKER_ARGS[${#DOCKER_ARGS[@]}]="$1"
                shift
                ;;
            *)
            esac
        esac
    done

    IMAGE="wrapper-$1" ; shift

    docker run ${RM} -v "${WORK_DIR}:${WORK_DIR}" -w "${WORK_DIR}" "${DOCKER_ARGS[@]}" "${REPO}/${IMAGE}:${TAG}" "$@"
}
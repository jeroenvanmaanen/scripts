#!/bin/bash

set -e -x

BIN="$(cd "$(dirname "$0")" ; pwd)"

LINK=''
if [ ".$1" = '.--link' ]
then
    shift
    LINK="$1"
    shift
fi

PUBLIC_PORT=''
if [ ".$1" = '.--port' ]
then
    shift
    PUBLIC_PORT="$1"
    shift
fi

NAME="$1"
shift

TUNNEL_DIR="$(pwd)"
SETTINGS="${TUNNEL_DIR}/${NAME}.sh"
YAML="${TUNNEL_DIR}/${NAME}.yml"
if [ -e  "${YAML}" ] && ( [ \! -e "${SETTINGS}" ] || [ "${YAML}" -nt "${SETTINGS}" ] )
then
    H='#'
    cat > "${SETTINGS}" <<EOT
${H}!/usr/bin/false
${H} Generated file. Edit the YAML file instead.
EOT
    "${BIN}/yaml-to-properties.sh" "${YAML}" | "${BIN}/properties-to-bash.sh" >> "${SETTINGS}"
fi

FORWARD_SIZE=0

source "${SETTINGS}"

declare -a VOLUMES
declare -a VOLUME_ARGS
declare -a EXPOSE_ARGS


function add-volume-arg() {
    VOLUME_ARGS[${#VOLUME_ARGS[@]}]="$1"
}

function add-volume() {
    local OUTSIDE="$1"
    local INSIDE="${2:-${OUTSIDE}}"
    add-volume-arg '-v'
    add-volume-arg "${OUTSIDE}:${INSIDE}"
    VOLUMES[${#VOLUMES[@]}]="${INSIDE}"
    echo "Added volume ${OUTSIDE}:${INSIDE}" >&2
}

function add-expose-arg() {
    EXPOSE_ARGS[${#EXPOSE_ARGS[@]}]="$1"
}

function add-expose-port() {
    local PORT="$1"
    add-volume-arg '--expose'
    add-volume-arg "${PORT}"
    echo "Added expose port ${PORT}" >&2
}

function get-var() {
    local NAME="$1"
    eval "echo \${${NAME}}"
}

if [ -n "${LINK}" ]
then
    add-volume-arg --link
    add-volume-arg "${LINK}"
fi

if [ -n "${PUBLIC_PORT}" ]
then
    add-volume-arg -p
    add-volume-arg "${PUBLIC_PORT}"
fi

INDEX=0
while [ "${INDEX}" -lt "${FORWARD_SIZE}" ]
do
    DIRECTION="$(get-var "FORWARD_${INDEX}_DIRECTION")"
    case "${DIRECTION}" in
    out*)
        THIS_PORT="$(get-var "FORWARD_${INDEX}_THIS_PORT")"
        add-expose-port "${THIS_PORT}"
        ;;
    esac
    INDEX=$[${INDEX}+1]
done

TUNNEL_DIR="$(echo ~/.tunnel)"
SSH_DIR="$(echo ~/.ssh)"
add-volume "${TUNNEL_DIR}"
add-volume "${SSH_DIR}"
add-volume "${SSH_DIR}/known_hosts" '/root/.ssh/known_hosts'

for F in $(find ~/.ssh -type link -print)
do
    G="$(readlink -n "${F}")"
    DIR="$(dirname "${G}")"
    NEW='true'
    for V in "${VOLUMES[@]}"
    do
        echo "Compare: [${V}]: [${DIR}]"
        if [ ".${V}" = ".${DIR}" ]
        then
            NEW='false'
            break
        fi
    done
    if "${NEW}"
    then
        add-volume "${DIR}" "${DIR}"
    fi
done

CONTAINER_NAME="tunnel-${NAME}"

docker stop "${CONTAINER_NAME}" || true
docker rm "${CONTAINER_NAME}" || true

"${BIN}/run-docker-wrapped-command.sh" \
    -d --keep \
    --name "${CONTAINER_NAME}" \
    "${VOLUME_ARGS[@]}" \
    "${EXPOSE_ARGS[@]}" \
    ssh \
    "${BIN}/tunnel-helper.sh" --dir "${TUNNEL_DIR}" "${NAME}" "$@"
##    ls -l "${SSH_DIR}" /Volumes/Keys/ssh

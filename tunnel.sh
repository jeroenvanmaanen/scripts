#!/bin/bash

set -e -x

BIN="$(cd "$(dirname "$0")" ; pwd)"

declare -a DOCKER_ARGS
declare -a VOLUMES

function add-docker-arg() {
    DOCKER_ARGS[${#DOCKER_ARGS[@]}]="$1"
}

while [ ".${1#-}" != ".$1" ]
do
    OPT="$1"
    shift
    if [ ".${OPT}" = '.--' ]
    then
        break;
    fi
    case "${OPT}" in
    --link|-p)
        add-docker-arg "${OPT}"
        add-docker-arg "$1"
        shift
        ;;
    *)
        echo "Usage: $(basename "$0") [ --link <container> | -p [<ip>:]<host-port>:<container-port> ] ..."
    esac
done

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

function add-volume() {
    local OUTSIDE="$1"
    local INSIDE="${2:-${OUTSIDE}}"
    add-docker-arg '-v'
    add-docker-arg "${OUTSIDE}:${INSIDE}"
    VOLUMES[${#VOLUMES[@]}]="${INSIDE}"
    echo "Added volume ${OUTSIDE}:${INSIDE}" >&2
}

function add-expose-port() {
    local PORT="$1"
    add-docker-arg '--expose'
    add-docker-arg "${PORT}"
    add-docker-arg '-p'
    add-docker-arg "${PORT}:${PORT}"
    echo "Added expose port ${PORT}" >&2
}

function get-var() {
    local NAME="$1"
    eval "echo \${${NAME}}"
}

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
add-volume "/Users"
add-volume "${SSH_DIR}/known_hosts" '/root/.ssh/known_hosts'

CONTAINER_NAME="tunnel-${NAME}"

docker stop "${CONTAINER_NAME}" || true
docker rm "${CONTAINER_NAME}" || true

"${BIN}/run-docker-wrapped-command.sh" \
    -d --keep \
    --name "${CONTAINER_NAME}" \
    "${DOCKER_ARGS[@]}" \
    ssh \
    "${BIN}/tunnel-helper.sh" --dir "${TUNNEL_DIR}" "${NAME}" "$@"

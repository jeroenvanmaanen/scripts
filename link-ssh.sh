#!/bin/bash
# ssh to a linked container (e.g., a tunnel endpoint)

declare -a ARGUMENTS

function add-argument() {
    ARGUMENTS[${#ARGUMENTS[@]}]="$1"
}

CONTAINER="$1"
shift

USER_PART=''
IDENTITY="${HOME}/.ssh/id_rsa"

while [ ".$1" != ".${1#-}" ]
do
    OPT="$1"
    shift
    if [ ".${OPT}" = ".--" ]
    then
        break
    fi
    case "${OPT}" in
    -u|--user)
        USER_PART="$1@"
        shift
        ;;
    -p|--port)
        add-argument -p
        add-argument "$1"
        shift
        ;;
    -i)
        IDENTITY="$1"
        shift
        ;;
    -v|-vv|-vvv)
        add-argument "${OPT}"
        set +x
        ;;
    *)
        echo "Unknown option: ${OPT}" >&2
        exit 1
    esac
done

NAME="${CONTAINER}"
if [ -n "${USER}" ]
then
    NAME="${USER}_${NAME}"
    USER="${USER}@"
fi
NAME="ssh_${NAME}"

SSH_DIR="$(echo ~/.ssh)"
add-argument -i
add-argument "${IDENTITY}"
add-argument -o
add-argument "UserKnownHostsFile=${SSH_DIR}/known_hosts"

docker rm -f "${NAME}" || true

run-docker-wrapped-command.sh \
    --name "${NAME}" \
    -i -t \
    -v "${SSH_DIR}:${SSH_DIR}" \
    --link "${CONTAINER}" \
    ssh \
    ssh -i "${IDENTITY}" "${ARGUMENTS[@]}" "${USER_PART}${CONTAINER}" "$@"

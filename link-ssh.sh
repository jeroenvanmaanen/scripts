#!/bin/bash
# ssh to a linked container (e.g., a tunnel endpoint)

declare -a ARGUMENTS

function add-argument() {
    ARGUMENTS[${#ARGUMENTS[@]}]="$1"
}

CONTAINER="$1"
shift

USER_PART=''
IDENTITY='/Volumes/Keys/ssh/id_rsa'

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
        ;;
    *)
        echo "Unknown option: ${OPT}" >&2
        exit 1
    esac
done

if [ -n "${USER}" ]
then
    USER="${USER}@"
fi

SSH_DIR="$(echo ~/.ssh)"
add-argument -i
add-argument "${IDENTITY}"
add-argument -o
add-argument "UserKnownHostsFile=${SSH_DIR}/known_hosts"

run-docker-wrapped-command.sh -i -t -v /Volumes/Keys:/Volumes/Keys -v "${SSH_DIR}:${SSH_DIR}" --link "${CONTAINER}" ssh \
    ssh -i "${IDENTITY}" "${ARGUMENTS[@]}" "${USER_PART}${CONTAINER}" "$@"

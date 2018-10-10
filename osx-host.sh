#!/usr/bin/env bash

function get-host() {
    ifconfig lo0 | sed -n -e '/inet 127[.]0[.]0[.]1 /d' -e 's/ netmask .*//' -e 's/^.*inet //p' | head -1
}

HOST='host.docker.internal'
XHOST='localhost'
DOCKER_HOST_INTERNAL="$(docker run --rm -ti alpine nslookup 'host.docker.internal' | sed -n 's/^Address.*: *//p')"
if [ -z "${DOCKER_HOST_INTERNAL}" ]
then
    HOST="$(get-host)"
    if [ -z "${HOST}" ]
    then
        BRIDGE="$(docker network inspect -f '{{(index .IPAM.Config 0).Subnet}}' bridge)"
        NEW_IP="$(echo "${BRIDGE}" | sed -e 's:/[0-9]*$::' -e 's/[.][0-9]*$/.16/')"
        sudo ifconfig lo0 alias "${NEW_IP}"
        HOST="$(get-host)"
    fi
    XHOST="${HOST}"
fi

if [ -n "${HOST}" ]
then
    xhost "+${XHOST}" >/dev/null 2>&1
    echo "${HOST}"
fi

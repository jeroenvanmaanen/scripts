#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

FLAGS_INHERIT=()
source "${BIN}/verbose.sh"

HOME_DIR="$(cd ~ ; pwd)"

DOCKER_FLAGS=()
if "${SILENT}"
then
	:
else
	DOCKER_FLAGS[${#DOCKER_FLAGS[@]}]='--verbose'
fi
"${BIN}/run-docker-wrapped-command.sh" "${DOCKER_FLAGS[@]}" -v "${HOME_DIR}:/root" metapost /usr/bin/gs "$@"

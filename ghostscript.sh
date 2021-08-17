#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

FLAGS_INHERIT=()
source "${BIN}/verbose.sh"

SRC_DIR="$(cd ~/src ; pwd)"

DOCKER_FLAGS=()
if "${SILENT}"
then
	:
else
	DOCKER_FLAGS[${#DOCKER_FLAGS[@]}]='--verbose'
fi
"${BIN}/run-docker-wrapped-command.sh" "${DOCKER_FLAGS[@]}" -v "${SRC_DIR}:${SRC_DIR}" metapost /usr/bin/gs "$@"

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
"${BIN}/run-docker-wrapped-command.sh" "${DOCKER_FLAGS[@]}" -v "${HOME_DIR}:/root" metapost /usr/bin/mpost "$@"

for F in *.*[0-9]
do
  mv -f "${F}" "${F}.ps"
done

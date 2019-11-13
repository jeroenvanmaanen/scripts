#!/bin/bash

set -x

BIN="$(cd "$(dirname "$0")" ; pwd)"

HOME_DIR="$(cd ~ ; pwd)"

"${BIN}/run-docker-wrapped-command.sh" -v "${HOME_DIR}:/root" metapost /usr/bin/mpost "$@"

for F in *.*[0-9]
do
  mv -f "${F}" "${F}.ps"
done

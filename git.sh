#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

HOME_DIR="$(cd ~ ; pwd)"

"${BIN}/run-docker-wrapped-command.sh" -v "${HOME_DIR}:/root" git /usr/bin/git "$@"

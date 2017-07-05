#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"${BIN}/run-docker-wrapped-command.sh" -ti nodejs6 /usr/bin/npm "$@"

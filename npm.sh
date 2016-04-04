#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"${BIN}/run-docker-wrapped-command.sh" nodejs /usr/bin/npm "$@"
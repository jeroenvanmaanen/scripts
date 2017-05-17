#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

NODE_PATH="$1"
shift

"${BIN}/run-docker-wrapped-command.sh" -ti -e "NODE_PATH=${NODE_PATH}" nodejs /usr/bin/node "$@"
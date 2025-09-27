#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"

ssh -t jeroen@192.168.178.76 workspace/doodle/home-node/truenas/bin/dev.sh "${FLAGS_INHERIT[@]}" "$@"
tput init

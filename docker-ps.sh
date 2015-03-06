#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"${BIN}/docker-cli.py" -k Id -p12 -- containers "$@" | sed -e 's/^@//'

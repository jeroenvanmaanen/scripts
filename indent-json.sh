#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"${BIN}/indent.sh" '[[({]' '[])}]' "$@"
#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

cat "$@" | "${BIN}/flat-to-tsv-stdin.sh"

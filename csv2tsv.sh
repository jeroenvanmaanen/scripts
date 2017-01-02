#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

cat "$@" \
    | (
        cd "${BIN}"
        python ./csv2tsv.py
    )
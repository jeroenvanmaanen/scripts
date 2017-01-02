#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

TAB="$(echo -en '\011')"
"${BIN}/csv-to-flat.sh" -d "${TAB}" "$@"

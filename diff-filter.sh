#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"
source "${BIN}/lib-sed.sh"

LEFT="$1" ; shift
RIGHT="$1" ; shift

SED_ARGS=("$@")

function filter() {
  sed "${SED_EXT}" "${SED_ARGS[@]}"
}

diff -u <(cat "${LEFT}" | filter) <(cat "${RIGHT}" | filter)

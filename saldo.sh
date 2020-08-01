#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

PATTERN="$1"
shift
if [[ "$#" -eq 0 ]]
then
  set ./triodos-rabobank-and-ing.csv
fi

TAB="$(echo -ne '\011')"
(
  echo '0'
  grep "${PATTERN}" "$@" \
    | cut -d "${TAB}" -f 6,7 \
    | sed -e 's/^Af/_/' -e 's/Bij//' -e 's/,/./' -e 's/$/ +/' \
    | tr -d "${TAB}" ; echo p
) | dc

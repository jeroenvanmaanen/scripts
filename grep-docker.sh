#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"
source "${BIN}/lib-sed.sh"

if [[ ".$1" = '.--' ]]
then
  shift
fi

PATTERN="$1" ; shift

for F in "$@"
do
  log ">>> ${F}"
  cat "${F}" \
    | sed "${SED_EXT}" \
        -e '/\\$/!s/$/|/' \
    | tr '\012|' '|\012' \
    | fgrep docker \
    | grep -e "${PATTERN}" \
    | tr '\012|' '|\012' \
    | sed \
        -e 's/[|]$//' \
        -e '/^$/d' \
        -e "s|^|${F}:|"
done

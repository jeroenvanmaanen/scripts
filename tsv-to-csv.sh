#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

DELIMITER=';'
if [[ ".$1" = '.-d' ]]
then
  DELIMITER="$2"
  shift 2
fi

case "${DELIMITER}" in
.)
  ALLOWED=','
  ;;
,)
  ALLOWED='.'
  ;;
*)
  ALLOWED='.,'
esac

TAB="$(echo -ne '\011')"
"$BIN/utf8-bom-remove.sh" "$@" \
  | tr -d '\015' \
  | sed -E \
      -e 's/"/""/g' \
      -e "s/${TAB}/${TAB}${TAB}/g" \
      -e "s/^(.*)\$/${TAB}\\1${TAB}/" \
      -e "s/${TAB}([^${TAB}]*[^${TAB}0-9${ALLOWED}][^${TAB}]*)${TAB}/${TAB}\"\\1\"${TAB}/g" \
      -e "s/^${TAB}(.*)${TAB}\$/\\1/" \
      -e "s/${TAB}${TAB}/${DELIMITER}/g"

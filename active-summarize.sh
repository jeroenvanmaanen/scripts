#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

: ${SILENT:=false}
source "${BIN}/verbose.sh"

FILE="${HOME}/log/active.log"

log "$(wc -l "${FILE}")"

PATTERN="$1" ; shift

log "PATTERN=[${PATTERN}]"

if "${SILENT}"
then
  FILTER='/[a-z_]/'
else
  FILTER=''
fi

sed -e "/${PATTERN}/!d" -e 's/:[0-9][0-9] / /' -e 's/T/|/' -e 's/:/|/' -e 's/ /|/' -e 's/ .*//' "${FILE}" \
  | awk -f "${BIN}/active-summarize.awk" \
  | sed -n -e "${FILTER}p"

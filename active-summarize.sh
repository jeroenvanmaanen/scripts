#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

: ${SILENT:=false}
source "${BIN}/verbose.sh"

FILE="${HOME}/log/active.log"

log "$(wc -l "${FILE}")"

PATTERN="$1" ; shift

if [ -z "${PATTERN}" ]
then
	PATTERN="$(cat ~/log/active-summarize-pattern)"
else
	echo "${PATTERN}" > ~/log/active-summarize-pattern
fi

log "PATTERN=[${PATTERN}]"

if "${SILENT}"
then
  FILTER='/[a-z_]/'
else
  FILTER=''
fi

NOW="$(date '+%Y-%m-%dT%H:%M:%S %U')"
FINAL="${NOW} - ${PATTERN}
${NOW} - ~"

( cat "${FILE}" ; echo "${FINAL}" ) \
  | tr 'A-Z' 'a-z' \
  | sed -e 's/:[0-9][0-9] / /' -e 's/t/|/' -e 's/:/|/' -e 's/ /|/' -e 's/ -* */|/' \
  | awk -v "pattern=${PATTERN}" -f "${BIN}/active-summarize.awk" \
  | sed -n -e "${FILTER}p"

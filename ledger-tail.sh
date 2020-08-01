#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

ENTRIES_BASE='./triodos-rabobank-and-ing'
ENTRIES_FILE="${ENTRIES_BASE}.csv"
if test -f "${ENTRIES_FILE}"
then
  :
else
  error "Not found: ${ENTRIES_FILE}"
fi

LAST_ENTRY_DATE="$(curl -sS http://localhost:3000/api/last_entry/date | tr -dc '0-9')"
info "LAST_ENTRY_DATE=[${LAST_ENTRY_DATE}]"

TARGET_FILE="${ENTRIES_BASE}-after-${LAST_ENTRY_DATE}.csv"
"${BIN}/tsv-skip.sh" "${LAST_ENTRY_DATE}" "${ENTRIES_FILE}" >"${TARGET_FILE}"
tail +2 "${TARGET_FILE}" | wc -l

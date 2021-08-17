#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"

DELIMITER='|'
if [[ ".$1" = '.-d' ]]
then
  DELIMITER="$2"
  shift 2
fi

CSV_SOURCE=''
if [[ ".$1" = '.--file' ]]
then
  CSV_SOURCE="$2"
  shift 2
fi

CSV_FILE="$1"

if [[ -z "${CSV_FILE}" ]]
then
  CSV_FILE='-'
fi

if [[ -z "${CSV_SOURCE}" ]]
then
  CSV_SOURCE="${CSV_FILE}"
fi

if [[ ".${CSV_SOURCE}" = '.-' ]]
then
  error "CSV_SOURCE cannot be standard input"
fi

export LC_ALL=C
export LANG=C

cat "${CSV_FILE}" \
  | cut -d "${DELIMITER}" -f 1 \
  | sort \
  | uniq -d \
  | join -t "${DELIMITER}" - "$CSV_SOURCE"
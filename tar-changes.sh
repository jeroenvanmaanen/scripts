#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

. "${BIN}/verbose.sh"

log ARGS: "$@"

SED_EXT=-r
case "$(uname)" in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

if [ -z "${TMP}" ]
then
	TMP="${HOME}/tmp"
	mkdir -p "${TMP}"
fi

PROJECT="$(basename "$(pwd)")"
ARCHIVE="${TMP}/${PROJECT}-changes-$(date '+%Y%m%dT%H%M%S').tar.gz"

info "ARCHIVE: ${ARCHIVE}"

git status \
	| sed -n "${SED_EXT}" \
		-e 's/^	(modified|added): *//p' \
	| tar -cvzf "${ARCHIVE}" -T - "$@"

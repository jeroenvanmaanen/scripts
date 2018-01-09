#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

SED_EXT=-r
case $(uname) in
Darwin*)
	SED_EXT=-E
esac
export SED_EXT

if [ ".$1" = '.--help' ]
then
	echo "Usage: $(basename "$0") [ <field-number> <pattern> ] ..." >&2
	exit 0
fi

declare -a SED_ARGS
SED_ARGS=()

ACCOUNTS_FILE="${HOME}/project/~prive/accounts.csv"
if [ -e "${ACCOUNTS_FILE}" ]
then
	while
		IFS='	' read ACCOUNT CODE DESCRIPTION
	do
		log "ACCOUNT=[${ACCOUNT}]"
		log "CODE=[${CODE}]"
		log "DESCRIPTION=[${DESCRIPTION}]"
		SED_ARGS[${#SED_ARGS[@]}]='-e'
##		SED_ARGS[${#SED_ARGS[@]}]="s/([|][0-9]*[[][34]:[^:]:[0-9]*: )${ACCOUNT}[|]/\1${CODE}|/g"
		SED_ARGS[${#SED_ARGS[@]}]="s/${ACCOUNT}/${CODE}/g"
	done < "${ACCOUNTS_FILE}"
fi

while [ -n "$1" ]
do
	SED_ARGS[${#SED_ARGS[@]}]='-e'
	FIELD="$1"
	POSITIVE="$(expr ".${FIELD}" : '.-\([0-9]*\)' || true)"
	if [ -z "${POSITIVE}" ]
	then
		SED_ARGS[${#SED_ARGS[@]}]="/[|][0-9]*[[]${FIELD}:[^]]*[]]:[0-9]*: ($2)/!d"
	else
		SED_ARGS[${#SED_ARGS[@]}]="/[|][0-9]*[[]${POSITIVE}:[^]]*[]]:[0-9]*: ($2)/d"
	fi
	shift
	shift
done

for SED_ARG in "${SED_ARGS[@]}"
do
	log "SED_ARG=[${SED_ARG}]" >&2
done

tr '\011,.' ',. ' < triodos-and-ing.csv \
	| csv-to-flat.sh \
	| sed -e 's/^$/|/' \
	| tr '|\012' '\012|' \
	| sed "${SED_EXT}" "${SED_ARGS[@]}" \
	| tr '|\012' '\012|' \
	| sed -e 's/^[|]$//'

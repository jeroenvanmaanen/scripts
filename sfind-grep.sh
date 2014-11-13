#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/debug.sh"

SILENT='true'
TRACE='false'
if [ ".$1" = '.-v' ]
then
    shift
    SILENT='false'
    if [ ".$1" = '.-v' ]
    then
        shift
        TRACE='true'
        set -x
    fi
fi

declare -a GREP_OPTS
GREP_OPTS=()
while [ ".$1" != ".${1#-}" ]
do
	OPT="$1"
	shift
	if [ ".${OPT}" = '.--' ]
	then
		break
	fi
	debug OPT "${OPT}"
	GREP_OPTS[${#GREP_OPTS}]="${OPT}"
done

debug GREP_OPTS "${GREP_OPTS[@]}"

PATTERN="$1"
shift

debug PATTERN "${PATTERN}"

if [ -n "${PATTERN}" ]
then
    if [ "$#" -lt 1 ]
    then
        set '.'
    fi

    debug FIND_ARGS "$@"

    if [ ".$1" != ".${1#-}" ]
    then
        set * "$@"
    fi

    "${BIN}/sfind.sh" "$@" \! -type d -print0 | xargs -0 egrep -n "${GREP_OPTS[@]}" "${PATTERN}" /dev/null
fi

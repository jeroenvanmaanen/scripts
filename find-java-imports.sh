#!/bin/bash

set -e

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

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

declare -a SED_ARGS
if [ ".$1" = '.-f' ]
then
    shift
    SED_FILE="$1"
    shift
    debug 'SED_FILE' "${SED_FILE}"
    OIFS="${IFS}"
    IFS=$'\n'
    declare -a SED_COMMANDS=($(<"${SED_FILE}"))
    IFS="$OIFS"
    for SED_COMMAND in "${SED_COMMANDS[@]}"
    do
        if [ -n "${SED_COMMAND}" -a ".${SED_COMMAND}" = ".${SED_COMMAND#\#}" ]
        then
            SED_ARGS[${#SED_ARGS[@]}]='-e'
            SED_ARGS[${#SED_ARGS[@]}]="${SED_COMMAND}"
        fi
    done < "${SED_FILE}"
fi

debug 'SED_ARGS' "${SED_ARGS[@]}"

for D in "$@"
do
    (
        cd "${D}"
        "${BIN}/sfind-grep.sh" '^import\>' * -name '*.java' \
            | tr '/' '.' \
            | sed "${SED_EXT}" \
                -e '/^NO/s/[/][^/:]*:/:/' \
                -e 's/:[0-9]*:/:/' \
                -e '/:.*static/s/[.][^.]*$//' \
                -e 's/:import */:/' \
                -e 's/:static */:/' \
                -e '/^NO/s/[.][^.]*$//' \
                -e 's/^/:/' \
                "${SED_ARGS[@]}" \
            | sort | uniq \
            | "${BIN}/filter-java-imports.py"
    )
done

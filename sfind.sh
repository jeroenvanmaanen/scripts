#!/bin/bash

set -x

FIND_EXT_BEFORE=()
FIND_EXT_AFTER=(--regex-type posix-egrep)
case $(uname) in
Darwin*)
    FIND_EXT_BEFORE=(-E)
    FIND_EXT_AFTER=()
esac
export SED_EXT

declare -a PATHS
N=0
while [ "$#" -gt 0 -a "::${1#-}" = "::$1" -a "::$1" != "::(" -a "::$1" != '::!' ]
do
	PATHS[$N]="$1"
	N=$[$N+1]
	shift
done
## for D in "${PATHS[@]}"
## do
##	echo ">> $D" >&2
## done
/usr/bin/find "${FIND_EXT_BEFORE[@]}" "${PATHS[@]}" "${FIND_EXT_AFTER[@]}" \( -type d \( -name .svn -o -name tmp \) -prune \! -type d \) -o \( \( \! -type d -o \! -name .svn \) "$@" \)

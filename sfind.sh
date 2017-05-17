#!/bin/bash

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
/usr/bin/find -E "${PATHS[@]}" \( -type d \( -name .svn -o -name tmp \) -prune \! -type d \) -o \( \( \! -type d -o \! -name .svn \) "$@" \)

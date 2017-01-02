#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

declare -a OPTS
N=0
while [ "//${1#-}" != "//$1" ]
do
	OPT="$1"
	shift
	OPTS[$N]="$OPT"
	N=$[$N+1]
	case "$OPT" in
	-d|-k)	OPTS[$N]="$1"
		shift
		N=$[$N+1]
		;;
	--)	shift
		break
		;;
	*)	break
		;;
	esac
done

## echo "OPTS=[${OPTS[@]}]" >&2
## echo "ARGS=[$@]" >&2

## for OPT in "${OPTS[@]}"
## do
## 	echo "OPT=[$OPT]"
## done
## 
## for ARG in "$@"
## do
## 	echo "ARG=[$ARG]"
## done
		

"$BIN/utf8-bom-remove.sh" "$@" | "$BIN/csv-to-flat.php" -- "${OPTS[@]}"

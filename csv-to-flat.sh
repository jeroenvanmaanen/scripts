#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

declare -a OPTS
N=0
while [ "//${1#-}" != "//$1" ]
do
	OPT="$1"
	shift
	case "$OPT" in
	-d)
	  OPTS[$N]='-v'
		N=$[$N+1]
		OPTS[$N]="delim=$1"
		N=$[$N+1]
		shift
		;;
	-k)
	  OPTS[$N]='-v'
		N=$[$N+1]
		OPTS[$N]="key_indices=$1"
		N=$[$N+1]
		shift
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
		

"$BIN/utf8-bom-remove.sh" "$@" | awk "${OPTS[@]}" -f "$BIN/csv-to-flat.awk" -

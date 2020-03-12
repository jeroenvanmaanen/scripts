#!/usr/bin/false

LIB_VERBOSE_STATUS='loading'

: ${NARGS:=0}

FLAGS_INHERIT=()

SILENT='true'
TRACE='false'

: SCRIPT="${SCRIPT:=}"
if [ -z SCRIPT ]
then
  SCRIPT="$(basename "$0")"
fi

function message() {
	local TYPE="$1"
	shift
	echo "[${TYPE}] \$ ${SCRIPT}:" "$@" >&2
}

function usage() {
	message 'Usage' "$SCRIPT" "$@"
	exit 1
}

function error() {
	message 'ERROR' "$@"
	exit 1
}

function info() {
	message 'INFO' "$@"
}

function log() {
	"${SILENT}" || message 'DEBUG' "$@"
}

function trace() {
	"${TRACE}" && message 'TRACE' "$@" || true
}

if [ ".$1" = '.-v' ]
then
        SILENT='false'
        FLAGS_INHERIT[${#FLAGS_INHERIT[@]}]='-v'
        shift
        NARGS=$((${NARGS} + 1))
        if [ ".$1" = '.-v' ]
        then
                TRACE='true'
                FLAGS_INHERIT[${#FLAGS_INHERIT[@]}]='-v'
                set -x
                shift
                NARGS=$((${NARGS} + 1))
        fi
fi

trace FLAGS_INHERIT: "${FLAGS_INHERIT[@]}"

declare -a VERBOSE_OPTIONS
# Ruler:                             '  -<option>                         Explanation'
VERBOSE_OPTIONS[${#VERBOSE_OPTIONS}]='  -v                                Increase verbosity; once means DEBUG, twice means TRACE'

LIB_VERBOSE_STATUS='loaded'

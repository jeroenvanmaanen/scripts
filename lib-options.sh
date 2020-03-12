#!/usr/bin/false

LIB_OPTIONS_STATUS='loading'

if [[ -z "${BIN}" ]]
then
  BIN="$(cd "$(dirname "$0")" ; pwd)"
fi

source "${BIN}/lib-require.sh"
require verbose usage

: ${NARGS:=0}

function consume-arguments() {
  NARGS=$((${NARGS} + $1))
}

function consume-argument() {
  consume-arguments 1
}

function get-options() {
  while [[ ".${1#-}" != ".$1" ]]
  do
    OPT="$1" ; shift
    consume-argument
    trace "OPT=[${OPT}]"
    if [[ ".${OPT}" = '.--' ]]
    then
      break;
    fi
    get-option "${OPT}" "$@"
    if [[ ".${NARGS}" = '.ERROR' ]]
    then
      return 1
    fi
  done
}

function unknown-option() {
  info "Unknown option: '$1'"
  NARGS='ERROR'
  usage --rc 1
}

function end-options() {
  if [ ".$1" = '.--' ]
  then
      shift
  fi
}

LIB_OPTIONS_STATUS='loaded'

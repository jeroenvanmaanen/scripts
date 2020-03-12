#!/usr/bin/false

LIB_USAGE_STATUS='loading'

function show-usage() {
  local RC=0
  local AND=''
  local ONE_OF=''
  local BLOCK=''
  if [[ ".$1" = '.--rc' ]]
  then
    RC="$2"
    shift 2
  fi
  (
    echo "Usage: $(basename "$0") $1" >&2
    shift
    for LINE in "$@"
    do
      echo "${LINE}" >&2
    done

    if [[ "$#" -gt 0 ]]
    then
      AND='and '
    fi
    if [[ "${#VERBOSE_OPTIONS[@]}" -gt 1 ]]
    then
      ONE_OF=' one of'
    fi
    if [[ "${#VERBOSE_OPTIONS[@]}" -gt 0 ]]
    then
      echo "${AND}where <verbose-option> is${ONE_OF}:"
      for VERBOSE_OPTION in "${VERBOSE_OPTIONS[@]}"
      do
        echo "${VERBOSE_OPTION}"
      done
    fi
  ) >&2
  exit "${RC}"
}

LIB_USAGE_STATUS='loaded'

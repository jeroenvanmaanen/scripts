#!/bin/bash

BIN="$(cd "$(dirname "$0")" || exit ; pwd)"

source "${BIN}/lib-verbose.sh"

POST_PROCESS=(cat)
if [[ ".$1" = '.-print0'  ]]
then
  POST_PROCESS=(tr '\012' '\000')
  shift
fi

grep -Eli "$@" | "${POST_PROCESS[@]}"

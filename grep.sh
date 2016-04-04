#!/bin/bash

FILE="$1"
PATTERN="$2"
shift 2

egrep  "$@" "${PATTERN}" "${FILE}"

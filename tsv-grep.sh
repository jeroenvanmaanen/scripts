#!/bin/bash

FILE="$1" ; shift
FIELD="$1" ; shift

grep -i "	${FIELD}	" "${FILE}" "$@"

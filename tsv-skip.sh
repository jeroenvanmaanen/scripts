#!/usr/bin/env bash

PATTERN="$1" ; shift

cat "$@" \
    | sed \
        -e "2,/^${PATTERN}/d" \
        -e "/^${PATTERN}/d"

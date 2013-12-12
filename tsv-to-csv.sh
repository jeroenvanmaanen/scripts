#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"$BIN/utf8-bom-remove.sh" "$@" | sed -e 's/"/""/g' -e "s/$(echo -ne '\011')/\";\"/g" -e 's/^/"/' -e 's/$/"/'

#!/bin/bash

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

TAB="$(echo -ne '\011')"

cat "$@" \
  | sed "${SED_EXT}" \
      -e '/^202001/b' \
      -e "/^20[2-9]/s/(${TAB}NL72RABO0347617077)(${TAB})/\\1@2\\2/" \
      -e "/^20[2-9]/s/(${TAB}NL61INGB0004266631)(${TAB})/\\1@2\\2/"

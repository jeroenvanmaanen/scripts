#!/bin/bash

set -e

SED_EXT=-r
case "$(uname)" in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

cat "$@" | sed "${SED_EXT}" -e 's/([[{,])/\1|/g' -e 's/([]}])/|\1/g' -e 's/[|][|]*/|/g' -e 's/[|]$//' | tr '|' '\012'
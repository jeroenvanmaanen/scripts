#!/bin/bash

DIR='.'
if [[ ".$1" = '.--dir' ]]
then
  DIR="$2"
  shift 2
fi

if [[ ".$1" = '.--' ]]
then
  shift
fi

if [[ ! -d "${DIR}" ]]
then
  echo "Not a directory: [${DIR}]" >&2
  exit 1
fi

( cat "$@" ; echo ) \
  | sed -E \
      -e '/^[*] [*]/!d' \
      -e 's/^[*] [*]//' \
      -e 's/[*], */|/' \
      -e 's/, *([ 0-9]*)$/|\1/' \
      -e 's/[|]([^| ][^|A-Z]* ([^|, ]*))/|\2#\1/' \
      -e 's/[|]([^|#]*)[|]/|\1#\1|/' \
      -e 's/#/|/' \
  | (
      IFS='|'
      while read -r TITLE PREFIX AUTHORS YEAR
      do
        CODE="${PREFIX}${YEAR}"

        AUTHOR_LIST="$(echo "${AUTHORS}" | sed -e 's/ and /,/' | tr ',' '\012' | sed -e 's/^ */  - "/' -e 's/$/"/')"

        read -r -d '' ENTRY <<EOT
---
title: "${TITLE}"
authors:
${AUTHOR_LIST}
year: ${YEAR}
language: "en"
---
*${TITLE}*, ${AUTHORS}, ${YEAR}
EOT
        echo "--- Begin entry for ${CODE} ---"
        echo "${ENTRY}"
        echo "--- End entry for ${CODE} ---"
        FILE="${DIR}/${CODE}.md"
        echo "FILE: [${FILE}]"
        if [[ -f "${FILE}" ]]
        then
          echo "${ENTRY}" | diff "${FILE}" -
        fi
        echo "${ENTRY}" > "${FILE}"
      done
  )

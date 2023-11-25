#!/bin/bash

PROJECT="$(cd "$(dirname "$0")" ; pwd)"

source "${PROJECT}/lib-verbose.sh"

ACCOUNTS="${PROJECT}/data/local/account.list"

TAB="$(echo -ne '\011')"

cat "${ACCOUNTS}" \
  | (
      SED_ARGS=()
      while IFS=":" read -r ACCOUNT CODE
      do
        ## log "${CODE}: ${ACCOUNT}" 2>&1
        SED_ARGS[${#SED_ARGS[@]}]='-e'
        SED_ARGS[${#SED_ARGS[@]}]="s/${ACCOUNT}/${CODE}/g"
      done
      ## log "${SED_ARGS[@]}"
      ## ls */triodos*and-ing.csv
      csv-to-flat.sh -d "${TAB}" */triodos*and-ing.csv \
        | sed -e 's/^$/|/' "${SED_ARGS[@]}" \
        | tr '|\012' '\012|' \
        | egrep -i '3:rekening[]]:: M.*4:Tegenrekening[]]:: S.*6:Af Bij[]]:: Bij.*9:Mededelingen[]]::[^|](tekort|extra|eenmalig|aanv)' \
        | egrep -vi 'verkeerd|camper|bouw|budget maand|auto|notaris|boete|bekeuring|blooming|zakgeld|boomhiemke' \
        | tr '|\012' '\012|' \
        | sed -e 's/^[|]$//'
      echo ''
    )

#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"

if [ ".$1" = '.--help' ]
then
    echo "Usage: $(basename "$0") [ --help ] [ { -o | --output } combined.csv ]"
    exit 0
fi

OUTPUT="./triodos-rabobank-and-ing.csv"

if [[ ".$1" = '.-o' ]] || [[ ".$1" = '.--output' ]]
then
  OUTPUT="$2"
  shift 2
fi

function redirect-output() {
  if [[ ".${OUTPUT}" = '.-' ]]
  then
    cat
  else
    cat > "${OUTPUT}"
  fi
}

TAB="$(echo -ne '\011')"

function extend-sort-key() {
    local KEY="$1"
    sed -e "s/${TAB}/#${KEY}${TAB}/"
}

(
  cat Alle_rekeningen* | head -1 | tr ';' '\011' | tr -d '"' | sed -e 's/Mutatiesoort/MutatieSoort/'
  (
      cat Alle_rekeningen* | "${BIN}/csv-to-flat.sh" -d ';' | egrep -v '^[^[]*[[]1[01]:' | "${BIN}/flat-to-tsv.sh" | tail +2
      cat mutations* | "${BIN}/triodos-to-ing.sh" | extend-sort-key 'a'
      cat CSV_* | "${BIN}/rabobank-to-ing.sh" | extend-sort-key 'b'
  ) | sort \
    | sed -e "/^[^${TAB}]*#/s/#[^${TAB}]*//" \
    | "${BIN}/swap-IJ-and-P.sh"
) | redirect-output

#EOF

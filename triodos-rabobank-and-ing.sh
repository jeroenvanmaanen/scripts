#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

if [ ".$1" = '.--help' ]
then
    echo "Usage: $(basename "$0") > combined.csv"
    exit 0
fi

TAB="$(echo -ne '\011')"

function extend-sort-key() {
    local KEY="$1"
    sed -e "s/${TAB}/#${KEY}${TAB}/"
}

cat Alle_rekeningen* | head -1 | tr ',' '\011' | sed -e 's/Mutatiesoort/MutatieSoort/'
(
    cat Alle_rekeningen* | "${BIN}/csv-to-flat.sh" | "${BIN}/flat-to-tsv.sh" | tail +2
    cat mutations* | "${BIN}/triodos-to-ing.sh" | extend-sort-key 'a'
    cat CSV_* | "${BIN}/rabobank-to-ing.sh" | extend-sort-key 'b'
) | sort \
    | sed -e "/^[^${TAB}]*#/s/#[^${TAB}]*//" \
    | "${BIN}/swap-IJ-and-P.sh"
#EOF

#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

export LC_ALL='C'

cat "$@" \
    | "${BIN}/csv-to-flat.sh" -k 5 \
    | sed "${SED_EXT}" \
        -e '/^([^[]*)[[](2|3|4|6|8|11|12|13|15|16|17|18|23|24|25|26):/d' \
        -e 's/^([^[]*)[[]5:(Datum)/\1[1:\2/' \
        -e '/^[^[]*[[]1:Datum[]]:: /s/([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])$/\1\2\3/' \
        -e 'h' \
        -e 's/^([^[]*)[[](7:Bedrag]:): [-+]/\1:\2/p' \
        -e 'g' \
        -e 's/^([^[]*)[[]7:(Bedrag)/\1[6:Af Bij/' \
        -e '/^([^[]*)[[]6:(Af Bij)/s/[+][0-9,]*$/Bij/' \
        -e '/^([^[]*)[[]6:(Af Bij)/s/-[0-9,]*$/Af/' \
        -e 's/^([^[]*)[[]10:(Naam tegenpartij)/\1[2:\2/' \
        -e 's/^([^[]*)[[]1:(IBAN\/BBAN)/\1[3:\2/' \
        -e 's/^([^[]*)[[]9:(Tegenrekening IBAN\/BBAN)/\1[4:\2/' \
        -e 's/^([^[]*)[[]14:(Code)/\1[5:\2/' \
        -e 's/^([^[]*)[[]20:(Omschrijving-)/\1[9:\2/' \
        -e 's/^([^[]*)[[]21:(Omschrijving-)/\1[10:\2/' \
        -e 's/^([^[]*)[[]22:(Omschrijving-)/\1[11:\2/' \
        -e 's/^([^[]*)[[]19:(Betalingskenmerk)/\1[12:\2/' \
        -e 's/^([^[]*)[[](.*)/\1:\2/' \
        -e 's/^([^[]*)[]]:: (.*)/\1:\2/' \
        -e 's/^$/-::-:-/' \
    | (
        declare -a ROW
        IFS=':'
        while read DATE FIELD_NR FIELD_NAME VALUE
        do
            log "DATE=[${DATE}]"
            log "FIELD_NR=[${FIELD_NR}]"
            log "FIELD_NAME=[${FIELD_NAME}]"
            if [ -z "${FIELD_NR}" ]
            then
                echo -en "${ROW[1]}\011" # Datum
                echo -en "${ROW[2]}\011" # Naam
                echo -en "${ROW[3]}\011" # Rekening
                echo -en "${ROW[4]}\011" # Tegenrekening
                echo -en "${ROW[5]}\011" | tr 'a-z' 'A-Z' # Code
                echo -en "${ROW[6]}\011" # Af Bij
                echo -en "${ROW[7]}\011" # Bedrag
                echo -en "Rabobank\011" # Soort
                TAB="$(echo -ne '\011')"
                MEDEDELINGEN="${ROW[9]}${TAB}${ROW[10]}${TAB}${ROW[11]}${TAB}${ROW[12]}"
                MEDEDELINGEN="$(echo "${MEDEDELINGEN}" | sed -e "s/${TAB}${TAB}*/ /g" -e 's/^ *//' -e 's/ *$//')"
                echo -e "${MEDEDELINGEN}" # Mededelingen...
                ROW=()
            else
                ROW[${FIELD_NR}]="${VALUE}"
            fi
        done
    )
#EOF

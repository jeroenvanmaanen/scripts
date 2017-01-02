#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

MUTATIONS_HEADER='"Datum","Rekening","Bedrag (EUR)","Af Bij","Naam / Omschrijving","Tegenrekening","Code","Mededelingen"'

( echo "${MUTATIONS_HEADER}" ; cat "$@" ) \
    | "${BIN}/csv-to-flat.sh" \
    | sed "${SED_EXT}" \
        -e '/^[^[]*[[]4:Af Bij[]]:: /s/Debet/Af/' \
        -e '/^[^[]*[[]4:Af Bij[]]:: /s/Credit/Bij/' \
        -e '/^[^[]*[[]6:Tegenrekening[]]:: /s/:: [A-Z0-9]* /:: /' \
        -e '/^[^[]*[[]1:Datum[]]:: /s/([0-9][0-9])-([0-9][0-9])-([0-9][0-9][0-9][0-9])$/\3\2\1/' \
        -e 's/^([^[]*)[[]2:(Rekening)/\1[3:\2/' \
        -e 's/^([^[]*)[[]3:(Bedrag)/\1[7:\2/' \
        -e 's/^([^[]*)[[]4:(Af Bij)/\1[6:\2/' \
        -e 's/^([^[]*)[[]5:(Naam)/\1[2:\2/' \
        -e 's/^([^[]*)[[]6:(Tegenrekening)/\1[4:\2/' \
        -e 's/^([^[]*)[[]7:(Code)/\1[5:\2/' \
        -e 's/^([^[]*)[[]8:(Mededelingen)/\1[9:\2/' \
        -e 's/^([^[]*)[[](.*)/\1:\2/' \
        -e 's/^([^[]*)[]]:: (.*)/\1:\2/' \
        -e 's/^$/-::-:-/' \
    | (
        declare -a ROW
        IFS=':'
        while read DATE FIELD_NR FIELD_NAME VALUE
        do
            ## echo "DATE=[${DATE}]" >&2
            ## echo "FIELD_NR=[${FIELD_NR}]" >&2
            if [ -z "${FIELD_NR}" ]
            then
                echo -en "${ROW[1]}\011"
                echo -en "${ROW[2]}\011"
                echo -en "${ROW[3]}\011"
                echo -en "${ROW[4]}\011"
                echo -en "${ROW[5]}\011"
                echo -en "${ROW[6]}\011"
                echo -en "${ROW[7]}\011"
                echo -en "Triodos\011"
                echo -e "${ROW[9]}"
                ROW=()
            else
                ## echo "FIELD_NR=[${FIELD_NR}]" >&2
                ROW[${FIELD_NR}]="${VALUE}"
            fi
        done
    )
#EOF

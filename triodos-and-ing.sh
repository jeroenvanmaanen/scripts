#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

head -1 Alle_rekeningen* | tr ',' '\011'
(
    cat Alle_rekeningen* | "${BIN}/csv-to-flat.sh" | "${BIN}/flat-to-tsv.sh" | tail +2
    cat mutations* | "${BIN}/triodos-to-ing.sh"
) | sort

#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

if [ ".$1" = '.--help' ]
then
	echo "Usage: $(basename "$0") > triodos-and-ing.csv"
	exit 0
fi

head -1 Alle_rekeningen* | tr ',' '\011'
(
    cat Alle_rekeningen* | "${BIN}/csv-to-flat.sh" | "${BIN}/flat-to-tsv.sh" | tail +2
    cat mutations* | "${BIN}/triodos-to-ing.sh"
) | sort

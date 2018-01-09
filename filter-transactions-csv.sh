#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

head -1 triodos-and-ing.csv

"${BIN}/filter-transactions.sh" "${FLAGS_INHERIT[@]}" "$@" \
	| "${BIN}/flat-to-tsv.sh"

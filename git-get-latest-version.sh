#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"
. "${BIN}/verbose.sh"

function list-remote-refs() {
	git ls-remote 2>/dev/null | grep '/[0-9]*[.][0-9]*[.][0-9]$' | \
		while read HASH REF
		do
			git show --no-notes --pretty='tformat:%ai|%H|%an|%D' "${HASH}" -s \
				| sed -n -e "s:[|]:|${REF}|:" -e 's:[|][^|]*/:|:' -e '/[|]/p'
		done
}
BEFORE="$1"

list-remote-refs | /usr/bin/sort | sed -e "/^[^|]*[|]$(echo "${BEFORE}" | sed -e 's/[.]/[.]/g')[|]/,\$d" | tail -1

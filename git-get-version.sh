#!/bin/bash

SED_EXT=-r
case "$(uname)" in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

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

list-remote-refs | /usr/bin/sort | sed "${SED_EXT}" -n -e "/^[^|]*[|]$(echo "${BEFORE}" | sed -e 's/[.]/[.]/g')([.].*)?[|]/p" | tail -1

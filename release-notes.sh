#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

. "${BIN}/verbose.sh"

SED_EXT=-r
case "$(uname)" in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

THIS_VERSION=''
THIS_COMMIT=''
PREV_VERSION=''
PREV_COMMIT=''

PROJECT="$(pwd)"
while [ -n "${PROJECT}" -a "${PROJECT}" != '/' -a \! -d "${PROJECT}/.git" ]
do
	PROJECT="$(dirname "${PROJECT}")"
done
PROJECT_NAME="$(basename "${PROJECT}" | tr 'a-z' 'A-Z')"
PROJECT_PREFIX="$(echo "${PROJECT_NAME}" | tr 'A-Z' 'a-z')"
log "PROJECT_NAME=[${PROJECT_NAME}]"

SPEC="$1"
shift
if [ ".${SPEC}" = '.latest' ]
then
	SPEC=''
fi

if [ -n "${SPEC}" ]
then
	THIS="$("${BIN}/git-get-version.sh" "${SPEC}")"
	THIS_VERSION="$(echo "${THIS}" | cut -d '|' -f 2)"
	THIS_COMMIT="$(echo "${THIS}" | cut -d '|' -f 3)"
else
	THIS="$("${BIN}/git-get-latest-version.sh")"
	THIS_VERSION="$(echo "${THIS}" | cut -d '|' -f 2)"
	THIS_COMMIT="$(echo "${THIS}" | cut -d '|' -f 3)"
fi

if [ -n "$1" ]
then
	PREV="$("${BIN}/git-get-version.sh" "$1")"
	shift
	PREV_VERSION="$(echo "${PREV}" | cut -d '|' -f 2)"
	PREV_COMMIT="$(echo "${PREV}" | cut -d '|' -f 3)"
else
	PREV="$("${BIN}/git-get-latest-version.sh" "${THIS_VERSION}")"
	if [ -n "${PREV}" ]
	then
		PREV_VERSION="$(echo "${PREV}" | cut -d '|' -f 2)"
		PREV_COMMIT="$(echo "${PREV}" | cut -d '|' -f 3)"
	else
		PREV_VERSION='origin'
		PREV_COMMIT='origin'
	fi
fi

OUTPUT=''
if [ ".$1" = '.-o' ]
then
	OUTPUT="$1"
else
	OUTPUT="M:/RGN-Web - APPS/Documenten/_TR/Release notes/${PROJECT_PREFIX}-${THIS_VERSION}.html"
fi

cat >"${OUTPUT}" <<EOT
<html>
<head><title>${PROJECT_NAME}: Release notes of [${THIS_VERSION}]</title></head>
<body>
<h1>${PROJECT_NAME}: Release notes of [${THIS_VERSION}] <span style="color:#888">(since [${PREV_VERSION}])</span></h1>
<ul>
EOT

log "COMMITS [${THIS_COMMIT}] (since [${PREV_COMMIT}])"

git log "${PREV_COMMIT}..${THIS_COMMIT}" \
	| sed -e '/^commit/s/^/|/' \
	| tr '|\012' '\012|' \
	| sed "${SED_EXT}" \
		-e 's/[|][|]/|@|/' \
		-e 's/[|]@[|]    /|@|/' \
		-e 's/[|]    .*//' \
		-e '/[|]@[|][Mm]erge.*feature.*into .*(develop|master)/!d' \
		-e 's:^.*feature[s]?[-._/]([Tt][Aa][Ll][Ee][Nn][Tt][-._]?)?:TALENT-:' \
		-e 's/ into .*//' \
		-e "s/'$//" \
		-e 's;^(TALENT-[0-9]*)[-._/];<a href="https://randstad.prepend.net/jira/browse/\1">\1</a> ;' \
		-e 's/^/<li>/' \
		-e 's:$:</li>:' \
	| /usr/bin/sort \
	| uniq \
	>> "${OUTPUT}"
cat >>"${OUTPUT}" <<EOT
</ul>
</body>
</html>
EOT

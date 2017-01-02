#!/bin/bash

if [ -n "$1" ]
then
    echo "Usage: $(basename "$0") < input-flat.txt" >&2
fi

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

FIRST_RECORD=''
FIRST_RECORD_LINE='x'
while [ -n "${FIRST_RECORD_LINE}" ]
do
    IFS='' read -r 'FIRST_RECORD_LINE'
    FIRST_RECORD="${FIRST_RECORD}${FIRST_RECORD_LINE}
"
done

echo "FIRST_RECORD=[[
${FIRST_RECORD}]]" >&2

TAB="$(echo -ne '\011')"
CR="$(echo -ne '\015')"
echo "${FIRST_RECORD}" \
    | sed "${SED_EXT}" \
        -e "s/${CR}$//" \
        -e "s/^\$/${TAB}/" \
        -e 's/^[^:]*:/"/' \
        -e 's/[]]:.*$/"/' \
    | tr '\011\012' '\012\011' \
    | sed \
        -e "s/^${TAB}//" \
        -e '/^$/d'
( echo "${FIRST_RECORD}" ; cat ) \
    | sed "${SED_EXT}" \
        -e "s/${CR}$//" \
        -e "s/^\$/${TAB}/" \
        -e 's/^([^:]|:[^:])*:: //' \
    | tr '\011\012' '\012\011' \
    | sed \
        -e "s/^${TAB}//" \
        -e '/^$/d'

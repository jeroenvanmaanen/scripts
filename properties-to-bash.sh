#!/bin/bash

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

IFS=':'

SILENT='true'
function log() {
    "${SILENT}" || echo ">>> $*" >&2
}

function level() {
    local VAR="$1"
    echo "${VAR}" | tr -dc '.[' | wc -c | tr -dc '0-9'
}

function shell-var() {
    local VAR="$1"
    echo "${VAR}" \
        | sed "${SED_EXT}" \
            -e 's/([a-z])([A-Z])/\1_\2/g' \
        | tr 'a-z' 'A-Z' \
        | tr -sc 'A-Z0-9' '_' \
        | sed -e 's/_$//'
}

tr -d '\015' | \
    sed "${SED_EXT}" \
        -e 's/^([^:]*:[^:]*:[^:]*:) /\1/' \
        -e '/^[^:]*\[/!s/^([^:]*:)/\1:/' \
        -e 's/^([^:]*)\[/\1:[/' \
    | (
        declare -a COMPLEX
        LAST_VAR=''
        LINES=''
        while read -r VAR KEY TYPE NR VALUE
        do
            LEVEL="$(level "${VAR}")"
            if [ ".${TYPE}" = '.complex' ]
            then
                COMPLEX[${LEVEL}]="${VAR}"
                log "TUPLE: [${VAR}] <${COMPLEX[${LEVEL}]}>"
            else
                SHELL_VAR="$(shell-var "${VAR}")"
                log "TUPLE: [${VAR}] <${COMPLEX[${LEVEL}]}> {${SHELL_VAR}} [${KEY}] |${LEVEL}| <${TYPE}> [#${NR}] [${VALUE}]"

                if [ ".${VAR}" != ".${LAST_VAR}" ]
                then
                    if [ ".${VAR}" != ".${COMPLEX[${LEVEL}]}" -a -n "${KEY}" ]
                    then
                        echo "declare -a ${SHELL_VAR}"
                    fi
                fi
                LAST_VAR="${VAR}"

                if [ ".${TYPE}" = ".line" ]
                then
                    if [ ".${NR}" = '.1' ]
                    then
                        LINES="${VALUE}"
                    else
                        LINES="${LINES}
${VALUE}"
                    fi
                    if expr "${NR}" : '.*\([*]\)' > /dev/null
                    then
                        VALUE="${LINES}"
                    else
                        continue
                    fi
                fi

                if expr "${VALUE}" : ".*\\('\\).*" > /dev/null
                then
                    VALUE="$(echo "${VALUE}" | sed "${SED_EXT}" -e "s/([\"\\$])/\\\\\\1/g" -e '1s/^/"/' -e '$s/$/"/')"
                else
                    VALUE="'${VALUE}'"
                fi

                if [ ".${VAR}" = ".${COMPLEX[${LEVEL}]}" ]
                then
                    SHELL_VAR="$(shell-var "${VAR}[${KEY}]")"
                    echo "${SHELL_VAR}=${VALUE}"
                elif [ -n "${KEY}" ]
                then
                    echo "${SHELL_VAR}${KEY}=${VALUE}"
                else
                    echo "${SHELL_VAR}=${VALUE}"
                fi
            fi
        done
    )
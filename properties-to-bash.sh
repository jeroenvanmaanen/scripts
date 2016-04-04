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

tr -d '\015' | \
    sed "${SED_EXT}" -e 's/^([^:]*:[^:]*:[^:]*:) /\1/' -e 's/^([^.:[]*)/\1:/' | \
    (
        LAST_VAR=''
        COMPLEX=''
        LINES=''
        while read -r VAR KEY TYPE NR VALUE
        do
            if [ ".${TYPE}" = '.complex' ]
            then
                COMPLEX="${VAR}"
            else
                SHELL_VAR="$(echo "${VAR}" | sed "${SED_EXT}" -e 's/([a-z])([A-Z])/\1_\2/g' | tr 'a-z' 'A-Z')"
                log "TUPLE: [${VAR}] <${COMPLEX}> [${SHELL_VAR}] [${KEY}] [${TYPE}] [${NR}] [${VALUE}]"

                if [ ".${VAR}" != ".${LAST_VAR}" ]
                then
                    if [ ".${VAR}" = ".${COMPLEX}" ]
                    then
                        echo "declare -A ${SHELL_VAR}"
                    elif [ -n "${KEY}" ]
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
                    VALUE="$(echo "${VALUE}" | sed "${SED_EXT}" -e "s/([\"'\\$])/\\\\\\1/g" -e '1s/^/"/' -e '$s/$/"/')"
                else
                    VALUE="'${VALUE}'"
                fi

                if [ ".${VAR}" = ".${COMPLEX}" ]
                then
                    echo "${SHELL_VAR}['${KEY}']=${VALUE}"
                elif [ -n "${KEY}" ]
                then
                    echo "${SHELL_VAR}${KEY}=${VALUE}"
                else
                    echo "${SHELL_VAR}=${VALUE}"
                fi
            fi
        done
    )
#!/usr/bin/false
# This is a libary and cannot be run from the command line

if [ -z "${BIN}" ]
then
    BIN="$(cd "$(dirname "$0")" ; pwd)"
fi

function update-settings() {
    local SETTINGS="$1"
    local YAML="$(dirname "${SETTINGS}")/$(basename "${SETTINGS}" .sh).yml"
    local H='#'

    if [ -e  "${YAML}" ] && ( [ \! -e "${SETTINGS}" ] || [ "${YAML}" -nt "${SETTINGS}" ] )
    then
        cat > "${SETTINGS}" <<EOT
${H}!/usr/bin/false
${H} Generated file. Edit the YAML file instead.
EOT
        echo ">>> YAML: [${YAML}]: BIN: [${BIN}]"
        cat "${YAML}"
        "${BIN}/yaml-to-properties.sh" "${YAML}" | "${BIN}/properties-to-bash.sh" >> "${SETTINGS}"
    fi
}

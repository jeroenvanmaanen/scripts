#!/usr/bin/false

if [[ -z "${BIN}" ]]
then
  BIN="$(cd "$(dirname "$0")" ; pwd)"
fi

function get-var {
  eval "echo \"\$$1\""
}

function set-var {
  local VALUE="'$(echo "$2" | sed -e "s/'/'\\''/g")'"
  eval "$1=${VALUE}"
}

function require() {
  local STATUS
  local MODULES=("$@")
  set -- "${ARGV[@]}"
  for M in "${MODULES[@]}"
  do
    M_UC="$(echo "${M}" | tr -- '-a-z' '_A-Z')"
    VAR="LIB_${M_UC}_STATUS"
    STATUS="$(get-var "${VAR}")"
    if [[ -z "${STATUS}" ]]
    then
      set-var "${VAR}" 'loading'
      SCRIPT_FILE="${BIN}/lib-${M}.sh"
      ## echo "Loading ${M}: ${SCRIPT_FILE}" >&2
      source "${SCRIPT_FILE}"
      set-var "${VAR}" 'loaded'
    elif [[ ".${STATUS}" = '.loading' ]]
    then
      ## echo "Recursively loading ${M} is not allowed. (Check if it possible to use 'require-lax'.)"
      return 1
    else
      : ## echo "Module ${M} ${STATUS}" >&2
    fi
  done
}
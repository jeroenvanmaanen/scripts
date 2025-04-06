#!/bin/bash

BIN="$(cd "$(dirname "$0")" || exit ; pwd)"

source "${BIN}/lib-verbose.sh"

function awk_script() {
  local N='0'
  echo 'BEGIN {'
  for FIELD_NAME in "$@"
  do
    N=$(( N + 1 ))
    echo "  field_names[${N}] = \"${FIELD_NAME}\";"
  done
  echo "  last_field = ${N};"
  cat <<'EOT'
}
{
  values = "";
  remainder = "|" $0 "|";
  for (i = 1; i <= last_field; i++) {
    prefix = field_names[i] ":";
    prefix_length = length(prefix);
    value = "";
    for (j = 1; j <= NF; j++) {
      if (substr($j, 1, prefix_length) == prefix) {
        value = substr($j, prefix_length + 1, length($j) - prefix_length);
        gsub(/^ */, "", value);
        gsub("[|]" prefix "[^|]*[|]", "|", remainder);
        break;
      }
    }
    if (i > 1) {
      values = values "|";
    }
    values = values value;
  }
  if (remainder == "|") {
    remainder = "";
  }
  print values remainder;
}
EOT
}

FIELD_NAMES=()
while [[ $# -gt 0 ]] && [[ ".$1" != '.--' ]]
do
  FIELD_NAMES+=("$1")
  shift
done
log "FIELD_NAMES=[${FIELD_NAMES[*]}]"

if [[ ".$1" == '.--' ]]
then
  shift
fi

awk -F '|' "$(awk_script "${FIELD_NAMES[@]}")" "$@"

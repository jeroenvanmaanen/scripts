#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"${BIN}/osx-log-ssid.sh"

echo "$(basename $0 .sh)" | tee "${HOME}/log/time-type"

"${BIN}/osx-log-ssid.sh"

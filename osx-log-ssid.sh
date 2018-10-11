#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

mkdir -p ~/log

echo "$(date '+%Y-%m'-%dT%H:%M:%S) - $("${BIN}/osx-get-ssid.sh")" >> ~/log/active.log

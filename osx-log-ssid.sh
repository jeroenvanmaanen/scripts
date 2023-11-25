#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

mkdir -p ~/log

function get-search-domain() {
	if [[ -r /etc/resolv.conf ]]
	then
		sed -n -e 's/^search[ 	]*//p' -e 's/^domain[ 	]*//p' /etc/resolv.conf | head -1
	fi
}

NOW_TIMESTAMP="$(date '+%Y-%m-%dT%H:%M:%S %U')"
SSID="$("${BIN}/osx-get-ssid.sh")"
SEARCH_DOMAIN="$(get-search-domain)"
TIME_TYPE="$(cat "${HOME}/log/time-type")"

echo "${NOW_TIMESTAMP} - ${SSID} ${SEARCH_DOMAIN} ${TIME_TYPE}" >> ~/log/active.log

(
  tar -C ~/log -cf - . | tar -C ~/Dropbox/TFG/log -xf -
) || true

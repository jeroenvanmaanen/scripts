#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

mkdir -p ~/log

function get-search-domain() {
	if [[ -r /etc/resolv.conf ]]
	then
		sed -n -e 's/^search[ 	]*//p' -e 's/^domain[ 	]*//p' /etc/resolv.conf | head -1
	fi
}

echo "$(date '+%Y-%m-%dT%H:%M:%S %U') - $("${BIN}/osx-get-ssid.sh") $(get-search-domain)" >> ~/log/active.log

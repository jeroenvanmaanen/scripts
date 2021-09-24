#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

"${BIN}/active-summarize.sh" 'work|ns-ka-internet'

#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"
TARGET="${BIN}/target"

set -e

"${BIN}/nodejs.sh" "${BIN}/target/yaml/node_modules" "${BIN}/src/yaml/yaml-to-properties.js" "$@"
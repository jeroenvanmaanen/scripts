#!/bin/bash

set -e -x

BIN="$(cd "$(dirname "$0")" ; pwd)"
SRC="$(dirname "${BIN}")"
SCRIPTS="$(dirname "${SRC}")"
YAML="${SCRIPTS}/target/yaml"

(
    mkdir -p "${YAML}"
    cd "${YAML}"
    "${SCRIPTS}/npm.sh" install js-yaml
)
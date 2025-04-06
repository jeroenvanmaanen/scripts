#!/bin/bash

BIN="$(cd "$(dirname "$0")" || exit ; pwd)"

source "${BIN}/lib-verbose.sh"

SITE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${SITE_DIR}" ]]
then
  SITE_DIR="$(pwd)"
fi
log "Site directory: [${SITE_DIR}]"

docker run --rm -v "${SITE_DIR}:/site" bretfisher/jekyll "$@"

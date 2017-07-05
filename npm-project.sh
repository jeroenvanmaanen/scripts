#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

. "${BIN}/verbose.sh"

PROJECT="$(pwd)"
PROJECT_NAME="$(echo "${PROJECT}" | tr -c -s 'a-zA-Z0-9.-' '_' | sed -e 's/^[-_.]*//' -e 's/[-_.]*$//')"
DATA_NAME="${PROJECT_NAME}_data"

docker volume inspect "${DATA_NAME}" || true

docker volume create --name "${DATA_NAME}"

"${BIN}/run-docker-wrapped-command.sh" -v "${DATA_NAME}:/usr/lib/node_modules" -ti nodejs6 /usr/bin/npm -g "$@"

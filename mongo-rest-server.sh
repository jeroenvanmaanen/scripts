#!/bin/bash

set -e

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/verbose.sh"

function usage() {
    echo "Usage: $(basename "$0") [ -d <database-name> ] <mongo-container>" >&2
    exit 1
}

DATABASE='default'
while [ ".${1#-}" != ".$1" ]
do
    OPT="$1"
    shift
    case "${OPT}" in
    -d|--database)
        DATABASE="$1"
        shift
        ;;
    *)
        usage
    esac
done

MONGO_CONTAINER="$1"
if [ -z "${MONGO_CONTAINER}" ]
then
    usage
fi

REST_CONTAINER="${MONGO_CONTAINER}-rest"

docker run \
    -d \
    -p 3000:3000 \
    --link "${MONGO_CONTAINER}:mongodb" \
    -e ME_CONFIG_DBSTRING="mongodb://mongodb:27017/${DATABASE}" \
    --name "${REST_CONTAINER}" \
    jeroenvm/mongo-rest
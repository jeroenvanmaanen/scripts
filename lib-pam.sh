#!/usr/bin/false

function docker-pam() {
  DIR="$1" ; shift
  docker run --rm -v "${DIR}:${DIR}" -w "${DIR}" mapsherpa/ubuntu-build "$@"
}

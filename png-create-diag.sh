#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"
PROJECT="$(dirname "${BIN}")"

function docker-netpbm() {
  docker run --rm -v "${HOME}/tmp:${HOME}/tmp" -w "${HOME}/tmp" mapsherpa/ubuntu-build "$@"
}

IMG_DIM='75'
HALF_THICKNESS='3'
THICKNESS=$(($HALF_THICKNESS * 2 + 1))

PNG="${HOME}/tmp/diagonal.pgm"

(
  echo "P2"
  echo "# diagonal.pgm"
  echo "${IMG_DIM} ${IMG_DIM}"
  echo "7"
  N=0
  while [[ "${N}" -lt "${IMG_DIM}" ]]
  do
    X=$(($IMG_DIM - $N - $HALF_THICKNESS - 1))
    P=0
    while [[ "$P" -lt "${X}" ]]
    do
      echo -n ' 7'
      P=$(($P + 1))
    done
    Y=$(($IMG_DIM - $N + $HALF_THICKNESS))
    while [[ "$P" -lt "${Y}" ]] && [[ "$P" -lt "${IMG_DIM}" ]]
    do
      echo -n ' 0'
      P=$(($P + 1))
    done
    while [[ "$P" -lt "${IMG_DIM}" ]]
    do
      echo -n ' 7'
      P=$(($P + 1))
    done
    echo ''
    N=$(($N + 1))
  done
) > "${PNG}"

docker-netpbm pnmtopng -transparent 'white' "${PNG}" > "${HOME}/tmp/diagonal-${IMG_DIM}.png"

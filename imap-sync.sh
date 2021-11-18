#!/bin/bash

BIN="$(cd "$(dirname "$0")" ; pwd)"

source "${BIN}/lib-verbose.sh"
source "${BIN}/lib-sed.sh"

function imap-sync() {
  echo docker run amitdalal/imapsync imapsync "$@" | sed "${SED_EXT}" -e 's/(--password[12]) [^ ]*/\1 ****/g'
  docker run amitdalal/imapsync imapsync "$@"
}

SYNC_ARGS=()

function add-arg() {
  SYNC_ARGS[${#SYNC_ARGS[@]}]="$1"
}

function add-flag() {
  local NAME="$1"
  local VALUE="$2"
  add-arg "--${NAME}"
  add-arg "${VALUE}"
}

IMAP_USER="$1" ; shift
IMAP_SRC="$1" ; shift
IMAP_DST="$1" ; shift

TRIPLE_SRC="$(grep "^${IMAP_USER}-${IMAP_SRC}:" ~/.security/imap/passwords)"
TRIPLE_DST="$(grep "^${IMAP_USER}-${IMAP_DST}:" ~/.security/imap/passwords)"

IFS=: read ID_1 USER_1 PASSWD_1 < <(echo "${TRIPLE_SRC}")
IFS=: read ID_2 USER_2 PASSWD_2 < <(echo "${TRIPLE_DST}")

if [[ -z "${ID_1}" ]]
then
  error "Not found: ${IMAP_USER}-${IMAP_SRC}"
fi

if [[ -z "${ID_2}" ]]
then
  error "Not found: ${IMAP_USER}-${IMAP_DST}"
fi

add-flag host1 mail.mxes.net
add-flag user1 "${USER_1}"
add-flag password1 "${PASSWD_1}"
add-arg --ssl1
add-flag port1 143

add-flag host2 imap.freedom.nl
add-flag user2 "${USER_2}"
add-flag password2 "${PASSWD_2}"
add-arg --ssl2
add-flag port1 993

## add-arg --justconnect
add-arg --noauthmd5

imap-sync "${SYNC_ARGS[@]}"
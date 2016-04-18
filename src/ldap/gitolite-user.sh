#!/bin/bash

if [ $# -ne 3 ]
then
        echo "Usage: $(basename "$0") <ldap-settings> <public-key-directory> <user-id>"
        exit 1
fi
LDAP_SETTINGS="$1"
PUB_KEY_DIR="$2"
USER_ID="$3"

LDAP_HOST='localhost'
LDAP_BIND_DN=''
LDAP_BIND_PW=''
LDAP_SEARCH_BASE='dc=example,dc=com'
LDAP_SCOPE='subtree'
source "${LDAP_SETTINGS}"

declare -a LDAP_OPTIONS

function append-ldap-option() {
    LDAP_OPTIONS[${#LDAP_OPTIONS[@]}]="$1"
}

function append-ldap-options() {
    for OPTION in "$@"
    do
        append-ldap-option "${OPTION}"
    done
}

append-ldap-options -h "${LDAP_HOST}" -x
if [ -n "${LDAP_BIND_DN}" ]
then
    append-ldap-options -D "${LDAP_BIND_DN}"
    if [ -n "${LDAP_BIND_PW}" ]
    then
        append-ldap-options -w "${LDAP_BIND_PW}"
    fi
fi
append-ldap-options -b "${LDAP_SEARCH_BASE}" -s "${LDAP_SCOPE}" -LLL

# The search filter for the given USER_ID
LDAP_GROUP_FILTER="(&(objectClass=posixGroup)(memberUid=${USER_ID}))"

# Execute the LDAP search to get groups for the given USER_ID
GROUPS="$(ldapsearch "${LDAP_OPTIONS[@]}" "${LDAP_GROUP_FILTER}" cn | sed -n -e 's/^cn: *//p' | tr -s '\000- ' ' ' | sed -e 's/ *$//')"

if [ -n "${GROUPS}" ]
then
    LDAP_PUB_KEY_FILTER="(&(objectclass=ldapPublicKey)(uid=${USER_ID}))"
    PUBLIC_KEY="$(ldapsearch "${LDAP_OPTIONS[@]}" "${LDAP_PUB_KEY_FILTER}" sshPublicKey | sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;s/sshPublicKey: //gp')"
    if [ -n "${PUB_KEY_DIR}" ]
    then
        echo "${PUBLIC_KEY}" > "${PUB_KEY_DIR}/${USER_ID}.pub"
    fi
fi

# Return group names for given user UID
echo "${GROUPS}"

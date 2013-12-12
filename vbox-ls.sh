#!/bin/bash

SCRIPTS="$(cd "$(dirname "$0")" ; pwd)"

SILENT='true'
TRACE='false'

while [ "$#" -gt 0 -a ".${1#-}" != ".$1" ]
do
    OPT="${1#-}"
    shift
    "${SILENT}" || echo "OPT=[${OPT}]"
    case "${OPT}" in
    v)  if "${SILENT}"
        then
            SILENT='false'
        else
            TRACE='true'
            set -x
        fi
        ;;
    *)  echo "Unknown option: -${OPT}"
        usage
    esac
done

PROCESS_RECORD='
    project = "?";
    if (disks["\"v-project\""]) {
        project = disks["\"v-project\""];
    }
    if (disks["\"/vagrant_project\""]) {
        project = disks["\"/vagrant_project\""];
    }
    sub(/\/Users\/jeroen\/src\//, "", project);
    printf("%s   \t%s %s\n", record["VMState"], box, project);
    if (0) {
        for (x in disks) {
            print box, x, disks[x];
        }
    }
'

AWK_SCRIPT="
BEGIN {
    delete record;
    delete disks;
    box = \"\";
}
{
    if (\$1 != box) {
        if (box != \"\") {
            ${PROCESS_RECORD}
        }
        delete record;
        delete disks;
        box = \$1;
    }
    record[\$2] = \$3;
}
\$2 ~ /^SharedFolderPathMachineMapping[0-9]/ {
    path = \$3;
    key = \$2;
    sub(/Path/, \"Name\", key);
    disks[record[key]] = \$3;
}
END {
    ${PROCESS_RECORD}
}
"

"${SILENT}" || echo "AWK_SCRIPT=[${AWK_SCRIPT}]"

"${SCRIPTS}/vbox-info.sh" | awk -v FS='|' "${AWK_SCRIPT}"

"${SILENT}" || echo "Done."

#!/bin/bash

OPEN_RE="$1"
shift
CLOSE_RE="$1"
shift

cat "$@" | awk -v open_re="${OPEN_RE}" -v close_re="${CLOSE_RE}" '
BEGIN {
    level = 0;
}
/./ {
    delimiters = $0;
    gsub(open_re, "(", delimiters);
    gsub(close_re, ")", delimiters);
    gsub(/[^()]/, "", delimiters);
    initialClosed = delimiters;
    sub(/[(].*/, "", initialClosed);
    allClosed = delimiters;
    gsub(/[(]/, "", allClosed);
    allOpened = delimiters;
    gsub(/[)]/, "", allOpened);
    thisLevel = level - length(initialClosed);
    level = level + length(allOpened) - length(allClosed);
##    print ">>> " delimiters ": " initialClosed ": " allClosed ": " allOpened ": " level;
    indent = "";
    while(thisLevel > 0) {
        indent = indent "  ";
        thisLevel = thisLevel - 1;
    }
    sub(/^[ \t]*/, "", $0);
    print indent $0;
}
'
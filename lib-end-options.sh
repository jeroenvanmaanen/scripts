#!/usr/bin/false

: ${NARGS:=0}

if [ ".$1" = '.--' ]
then
  NARGS=$((${NARGS} + 1))
  shift
fi

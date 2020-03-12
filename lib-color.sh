#!/usr/bin/false

LIB_COLOR_STATUS='loading'

: ${NARGS:=0}
: ${COLOR:=auto}

declare -a VERBOSE_OPTIONS
# Ruler:                             '  -<option>                         Explanation'
VERBOSE_OPTIONS[${#VERBOSE_OPTIONS}]='  --color <color-mode>              Where <color-mode> is either auto, yes, or no'

if [ ".$1" = '.--color' ]
then
  COLOR="$2"
  shift 2
  NARGS=$((${NARGS} + 2))
fi

log "COLOR=[${COLOR}]"

if [[ ".${COLOR}" = ".auto" ]] && [[ -t 1 ]]
then
  COLOR='yes'
fi

function stderr-color() {
  if [[ ".${COLOR}" = ".yes" ]]
  then
    exec 2> >("${BIN}/color.sh" >&2)
    sleep .1 # prevent race condition (https://stackoverflow.com/questions/30687504/redirected-output-hangs-when-using-tee)
  fi
}

stderr-color

LIB_COLOR_STATUS='loaded'

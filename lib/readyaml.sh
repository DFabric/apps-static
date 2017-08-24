#!/bin/sh
set -eu

# Parse yaml file
# Ability to get an object inside an object etc.

readyaml() {
  usage() {
    cat <<EOF
  readyaml.sh - parse yaml file

  Usage: readyaml.sh (type) [source] {object1} {object2} {object...}
  -f|--file   Text file
  -w|--web	  Web text file
  -h|--help   Print this help

  objects: No limits are set to get an objects inside an object
EOF
    exit $1
  }
  case $1 in
    -f|--file) yaml=$(cat $2); shift;;
    -w|--web) yaml=$(getstring $2); shift;;
    -h|--help) usage 0;;
    *) case $1 in
	    http://*|https://*) yaml=$(getstring $1);;
	    *) yaml=$(cat $1);;
	  esac;;
  esac
  parseloop() {
    inlinelist() {
      local IFS=', '
      for i in ${1% \]} ;do
      	printf '%s\n' "$i"
      done
    }
    local IFS='
'
    local start=false
    local loop=true
    printf '%b\n' "$1" | while read line && $loop ;do
      # Start parsing when the pattern match
      case $line in
        "$2: ["*) inlinelist "${line#*: \[ }"; loop=false;;
        "$2: "*) printf '%b\n' "${line#*: }"; loop=false;;
        "$2:") start=true;;
        "$2") printf '%s' "0" ;loop=false;;
      esac
      if $start ;then
        case "$line" in
          '  '*) printf '%b\n' "${line#*  }";;
          '- '*) printf '%b\n' "${line#*- }";;
          ''|"$2:"*|"- $2:"*) ;;
          *)  [ ${line%\#*} ] && loop=false;; # End of the block if no comments
        esac
      fi
    done
  }
  # Parse object inside objects
  while [ "${2:-}" ] ;do
    yaml=$(parseloop "$yaml" "$2")
    [ "$yaml" ] || return 1
    shift
  done
  printf '%b\n' "$yaml"
}

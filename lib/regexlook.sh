#!/bin/sh
set -eu

# basic POSIX lookbehind/lookforward implementation, using sed

# Network functions
if hash curl 2>/dev/null ;then
  getstring() { curl -Ls $@; }
elif hash wget 2>/dev/null ;then
  getstring() { wget -qO- $@; }
else
  echo "ERROR: curl or wget not found - you need to install either one of them"; exit 1
fi

regexlook() {
  local start=
  local end=
  local type=
  local regex=
  local source=
  usage() {
    cat <<EOF
  regexlook.sh - basic POSIX lookbehind/lookforward implementation

  Usage: regexlook.sh [regex] (type) [sources]
  -x|--exec   Executable file
  -f|--file   Text file
  -w|--web    Web text file
  -h|--help   Print this help

EOF
    exit $1
  }
  # Parse the arguments
  # Cut the words to match
  case ${1:-} in
    -x|--exec) type=bin; shift;;
    -f|--file) type=file; shift;;
    -w|--web) type=http; shift;;
    -h|--help) usage 0;;
    '') usage 1;;
    *) case ${2-} in
      http://*|https://*) type=http;;
      '') printf '%s' "$1"; exit 0;;
      *) if hash $2 2>/dev/null || [ -x "$2" ] 2>/dev/null ;then
          type=exec
        elif [ -r "$2" ] 2>/dev/null ;then
          type=file
        else
          exit 1
        fi;;
    esac;;
  esac
  regex=$(printf '%s' "$1" | sed 's|\\\\|\n1|g;s|\\|\n2|g;s|/|\\/|g;s|\n2||g;s|\n1|\\\\|g')
  shift
  source="$@"
  # Lookbehind
  case $regex in
    '(?<='*) start=${regex%%\)*}; start=${start#\(?<=};;
  esac

  # Lookforward
  case $regex in
    *'(?='*\)) end=${regex##*\(?=}; end=${end%\)};;
  esac
  mid=${regex#*$start\)}
  mid=${mid%%\(?=*}

  expr="s/.*$start\($mid\)$end.*/\1/p"

  # Different processing depending of the source type
  case $type in
    file) sed -n "$expr" $source;;
    bin) $source | sed -n "$expr";;
    http) getstring $source | sed -n "$expr";;
  esac
}

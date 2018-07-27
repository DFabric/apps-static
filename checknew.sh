#!/bin/sh
set -eu

cd $(pwd)/$(dirname $0)

usage() {
  cat <<EOF
usage: $0 (package) (architecture)
Check for new available packages versions.

Available packages:
$packages

Available architectures:
[x86-64, x86, armhf, arm64] (default: $ARCH)

EOF
  exit $1
}

case ${1-} in
  -h|--help) usage 0;
esac

# Libraries
. lib/env.sh
. lib/regexlook.sh
. lib/readyaml.sh

PACKAGES=$(wget -qO- $MIRROR/SHA512SUMS)

eval_version() {
  latest_ver=$(regexlook -w "$(readyaml -f source/$1/pkg.yml version regex)" "$(readyaml -f source/$1/pkg.yml version src)"| head -1)
  printf '%b' "\33[1;36m$1 - latest: $latest_ver\33[0m\n"
  echo "$PACKAGES" | sed -n "s/.*  $1_\(.*\)\.tar\.xz/\1/p" | while read line ;do
    version=${line%%_*}
    case $latest_ver in
      $version) printf '%b' "\33[0;32m${line#*_}: $version (latest)\33[0m\n";;
      *rc*|*beta*) printf '%b'  "\33[0;33m${line#*_}: $latest_ver (latest stable)\33[0m\n";;
      *) printf '%b' "\33[0;31m${line#*_}: $version (previous)\33[0m\n";;
    esac
  done
}

IFS='
'
for pkg in source/* ;do
  eval_version ${pkg#*/}
done


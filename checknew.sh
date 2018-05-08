#!/bin/sh
set -eu

cd $(pwd)/$(dirname $0)

. ./lib/env.sh

packages=$(wget -qO- $MIRROR/SHA512SUMS | sed -n "s/.*  \(.*\)_$SYSTEM.*/\1/p")

usage() {
  cat <<EOF
usage: $0 (package) (architecture)
Check for new available packages versions for $SYSTEM:

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
. lib/regexlook.sh
. lib/readyaml.sh

for pkg in $packages ;do
  latestver=$(regexlook -w "$(readyaml -f source/${pkg%_*}/pkg.yml version regex)" "$(readyaml -f source/${pkg%_*}/pkg.yml version src)"| head -1)
  case $latestver in
    ${pkg#*_}) printf '%b' "\33[0;32m${pkg%_*}: ${pkg#*_} is the latest\33[0m\n";;
    *rc*|*beta*) printf '%b'  "\33[0;33m${pkg%_*}: $latestver is available but doesn't appear to be a stable release\33[0m\n";;
    *) printf '%b' "\33[0;31m${pkg%_*}: $latestver available (current ${pkg#*_})\33[0m\n";;
  esac
done

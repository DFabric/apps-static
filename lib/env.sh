#!/bin/sh
# Set the environment variables
BUILDDIR=${BUILDDIR:-/tmp}

# Contain library archives and SHA512SUMS
MIRROR=https://bitbucket.org/dfabric/packages/downloads

COMPRESS=${COMPRESS:-true}

DEV=${DEV:-false}

nproc=4

KERNEL=linux

case $(uname -m) in
	x86_64) ARCH=x86-64;;
	i*86) ARCH=x86;;
	aarch64) ARCH=arm64;;
	armv7*) ARCH=armv7;;
  *) printf "Error: $(uname -m) - unsupported architecture\n"; usage 1;;
esac

# Output
info() { printf '%b\n' "\33[1;33mINFO\33[0m \33[1;39m$0\33[0m $1"; }

error() { printf '%b\n' "\33[1;31mERR!\33[0m \33[1;39m$0\33[0m '$1' - $2" >&2; exit 1; }

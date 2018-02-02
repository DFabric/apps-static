#!/bin/sh

# Set the environment variables
CONTAINERDIR=/tmp
BUILDDIR=${BUILDDIR-/tmp/apps-static}
COMPRESS=${COMPRESS-true}
DEV=${DEV-false}
QEMU_EXECVE=${QEMU_EXECVE-}
DTAG=${DTAG-latest}

# Contain library archives and SHA512SUMS
MIRROR=https://bitbucket.org/dfabric/packages/downloads

# System variables
nproc=$(grep processor /proc/cpuinfo | wc -l)
KERNEL=$(uname -s | tr A-Z a-z)

case $(uname -m) in
	x86_64) ARCH=x86-64;;
	i*86) ARCH=x86;;
	aarch64) ARCH=arm64;;
	armv7*) ARCH=armhf;;
	*) printf "Error: $(uname -m) - unsupported architecture\n"; usage 1;;
esac

SYSTEM=${KERNEL}_$ARCH


# Output
info() { printf '%b\n' "\33[1;33mINFO\33[0m \33[1;39m$0\33[0m $1"; }

error() { printf '%b\n' "\33[1;31mERR!\33[0m \33[1;39m$0\33[0m '$1' - $2" >&2; exit 1; }

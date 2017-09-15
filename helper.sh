#!/bin/sh
set -eu

# Current directory
DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

# Must match lib/env.sh
MIRROR=https://bitbucket.org/dfabric/packages/downloads

KERNEL=$(uname -s | tr A-Z a-z)

case $(uname -m) in
	x86_64) ARCH=x86-64;;
	i*86) ARCH=x86;;
	aarch64) ARCH=arm64;;
	armv7*) ARCH=armhf;;
  *) printf "Error: $(uname -m) - unsupported architecture\n"; usage 1;;
esac
ARCH=${3-$ARCH}

SYSTEM=${KERNEL}_$ARCH

# Network functions
if hash curl 2>/dev/null ;then
  download() { [ "${2-}" ] && curl -\#L "$1" -o "$2"; }
	getstring() { curl -Ls $@; }
elif hash wget 2>/dev/null ;then
  download() { [ "${2-}" ] && wget "$1" -O "$2"; }
	getstring() { wget -qO- $@; }
else
  error 'curl or wget not found' 'you need to install either one of them'
fi

usage() {
  cat <<EOF
usage: $0 [package] (version) (architecture)
The application will be installed in ~/.local

Available packages:
$(getstring $MIRROR/SHA512SUMS | sed -n "s/.*  \(.*\)_$SYSTEM.*/\1\]/p" | tr _ \[)

Available architectures:
[x86-64, x86, armhf, arm64] (default: $ARCH)


EOF
  exit $1
}

case ${1-} in
  -h|--help|'') usage 0;
esac

# Current shell used by the user
SH=${SHELL##*\/}

# Add $HOME/.local/bin to the path
local_path() {
	if ! [ "$(grep -o \$HOME/.local/bin ~/.${SH}rc)" ] ;then
		mkdir -p ~/.local
		echo 'PATH="$HOME/.local/bin:$PATH"' >> ~/.${SH}rc
		echo '$HOME/.local/bin:$PATH is added in your path.'
		echo "Restart a shell or use:"
		echo 'export PATH="$HOME/.local/bin:$PATH"'
	fi
}

sha512sums=$(getstring $MIRROR/SHA512SUMS)
package=$(printf "$sha512sums\n" | grep -o "$1_${2-.*}_$SYSTEM.tar.xz" || true)

if ! [ "$package" ] ;then
	echo "$1 package not found in $MIRROR"
	usage 1
else
	name=${package%.tar.xz}
	local_path
	cd /tmp

	# Very shasum
	shasum=$(printf "$sha512sums\n "| grep "$package")
	download $MIRROR/$package $package
	if [ "$shasum" = "$(sha512sum $package)" ] ;then
		echo "SHA512SUMS match"
	else
		echo "SHA512SUMS don't match"
		exit 1
	fi
	echo "Extracting..."
	tar xJf $package
	rm $package
	cp -rf $name/* ~/.local
	rm -rf $name
	echo "$name installed in $HOME/.local"
fi

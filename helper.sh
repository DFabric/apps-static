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
	armv7*) ARCH=armv7;;
  *) printf "Error: $(uname -m) - unsupported architecture\n"; usage 1;;
esac

SYSTEM=${KERNEL}_$ARCH

usage() {
  cat <<EOF
usage: $0 [package]
The application will be installed in ~/.local

Available packages:
$(wget -qO- $MIRROR/SHA512SUMS | sed -n "s/.*  \(.*\)_$SYSTEM.tar.bz2/\1\]/p" | tr _ \[)

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
	if ! [ "$(grep -o $HOME/.local/bin ~/.${SH}rc)" ] ;then
		mkdir -p ~/.local
		echo 'PATH="$HOME/.local/bin:$PATH"' >> ~/.${SH}rc
		echo "$HOME/.local/bin:$PATH is added in your path."
		echo "Restart a shell or use:"
		echo "export PATH=\"$HOME/.local/bin:$PATH\""
	fi
}


package="$(wget -qO- $MIRROR/SHA512SUMS | grep -o $1_.*_$SYSTEM.tar.bz2 || true)"

if ! [ "$package" ] ;then
	echo "$1 package not found in $MIRROR"
	usage 1
else
	name=${package%.tar.bz2}
	local_path
	cd /tmp
	wget $MIRROR/$package
	echo "Extracting..."
	tar xjf $package
	rm $package
	cp -rf $name/* ~/.local
	echo "$name installed in $HOME/.local"
fi

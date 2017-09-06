#!/bin/sh

set -eu

# Current directory
DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

mkdir -p build

usage() {
  cat <<EOF

Usage: build-static [package] [arch]

Options:

available packages:
$(ls -1 source)

available architectures:
You can build natively on the the desired architecture,
or if you are on x86_64, qemu can be used for cross-compiling.
- x86_64
- x86 (backward compatible on x86_64)
- armv7 (with qemu on x86_64)
- arm64 (with qemu on x86_64)

EOF
  exit $1
}

. lib/env.sh

if [ $(id -u) = 0 ] ;then
  error 'script runned as root' "This could be dangerous. To add yourself to the docker group: usermod -aG docker 'user'"
elif ! docker ps >/dev/null ;then
  error 'no Docker daemon' "not started or not available for $(whoami)"
fi

case ${1:-} in
  -h|--help|'') usage 0;
esac

PKG=$1

[ -d "source/$PKG" ] || { error "source/$PKG" 'not found.'; }

# Only x86_64 can cross-compile

[ "${2-}" ] && [ "$ARCH" != x86_64 ] && [ "$ARCH" != "$2" ] && { error "$ARCH" "only x86_64 can cross compile."; }

ARCH=${2:-$ARCH}
# cross-compile on x86_64

# Translate build arch to their Docker's equivalent
case $ARCH in
  arm64) DARCH=amr64v8;;
  armv7) DARCH=arm32v7;;
  x86-64) DARCH=amd64;;
  x86) DARCH=i386;;
  *) error "$ARCH" 'unsupported architecture';;
esac

#docker run -it --rm -v $PWD/qemu-$PKG-static:/bin/qemu -e QEMU_EXECVE=1 $PKG/$2 qemu /bin/sh

# Copy on the build directory
[ "$(ls $BUILDDIR/$PKG 2>/dev/null)" ] && error "$BUILDDIR/$PKG" 'already present, delete it first'
cp -r $DIR/source/$PKG $BUILDDIR
cp -r $DIR/lib $BUILDDIR/$PKG

# Compile from the source
info "Compiling $PKG for $ARCH for $BUILDDIR/$PKG"

if $DEV ;then
  info "You're actuallly on dev mode, you may need to run:
sh lib/main.sh"
  docker run -it --rm -e DEV=true -v $BUILDDIR/$PKG:$BUILDDIR/$PKG -w $BUILDDIR/$PKG alpine sh
else
  docker run -it --rm -v $BUILDDIR/$PKG:$BUILDDIR/$PKG -w $BUILDDIR/$PKG alpine sh lib/main.sh || true

  package=$(cd $BUILDDIR/$PKG; ls -d ${PKG}_*_$KERNEL.$ARCH*) \
  || { error "Build not found" "Your build is staying at $BUILDDIR/$PKG"; exit 1; }

  if [ "$package" ] && [ -d build/$package ] ;then
     error "$DIR/build/$package" "the file already exist!\
 Your build is staying at $BUILDDIR/$PKG"
     exit 1
  elif [ "$package" ] && mv -n "$BUILDDIR/$PKG/$package" "$DIR/build" && info "Your build is now at '$DIR/build/$package'" ;then
    rm -rf $BUILDDIR/$PKG
  else
    error "$BUILDDIR/$PKG/$package" "an error occured when moving  to $DIR/build!\
 Your build is staying at $BUILDDIR/$PKG/$package"
    exit 1
  fi
fi

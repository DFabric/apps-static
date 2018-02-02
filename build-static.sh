#!/bin/sh

set -eu

# Current directory
DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

mkdir -p build

. lib/env.sh

usage() {
  cat <<EOF
usage: $0 [package] (arch)

Available packages:
$(ls -1 source)

Available architectures:
[x86-64, x86, armhf, arm64] (default: $ARCH)
- can be a comma-separated list

EOF
  exit $1
}

parsearch() {
  local IFS=,
  for arch in $1 ;do
    ./build-static.sh $PKG $arch
  done
  info "builds completed for $1"
  exit
}

case ${1-} in
  -h|--help|'') usage 0;
esac


if [ $(id -u) = 0 ] ;then
  error 'script runned as root' "This could be dangerous. To add yourself to the docker group: usermod -aG docker 'user'"
elif ! docker ps >/dev/null ;then
  error 'no Docker daemon' "not started or not available for $(whoami)"
fi

PKG=$1
qemu=
QEMU_EXECVE=

case ${2-} in
  *,*) parsearch $2;;
esac

# Translate build arch to their Docker's equivalent
case ${2-$ARCH} in
  arm64) DARCH=arm64v8;;
  armhf) DARCH=armhf;;
  x86-64) DARCH=amd64;;
  x86) DARCH=i386;;
  *) error "${2-$ARCH}" 'unsupported architecture';;
esac
PKGDIR=$BUILDDIR/$PKG/${2-$ARCH}

# Check build directory
mkdir -p $PKGDIR
[ "$(ls $PKGDIR 2>/dev/null)" ] && error "$PKGDIR" 'already present, delete it first'
[ -d "source/$PKG" ] || { error "source/$PKG" 'not found.'; }

# No need of Qemu
if [ "${2-}" = x86 ] && [ "$ARCH" = x86-64 ]; then
  DARCH=i386

# Only x86_64 can cross-compile, for now
elif [ "${2-}" ] && [ "$ARCH" != x86-64 ] && [ "$ARCH" != "$2" ] ;then
  error "$ARCH" "only x86_64 can cross compile."

elif [ "${2-}" ] && [ "${2-}" != "$ARCH" ] ;then
  ARCH=$2
  case $ARCH in
    arm64) qemu=qemu-arm64-static_linux_x86-64;;
    armhf) qemu=qemu-armhf-static_linux_x86-64;;
    *) error "$ARCH" 'architecture not supported on qemu';;
  esac
  cd $BUILDDIR
  if ! [ -f "$BUILDDIR/$qemu" ] ;then
    BINMIRROR=https://bitbucket.org/dfabric/binaries/downloads
    info "Downloading $qemu"
    sha512sums=$(wget -qO- $BINMIRROR/SHA512SUMS) || error "$BINMIRROR/SHA512SUMS" "can't retrieve the file"
    package=$(printf '%b' "$sha512sums\n" | grep -o "${qemu}")
    wget "$BINMIRROR/$package"

    # Verify shasum
    shasum=$(printf "$sha512sums\n "| grep "$package")
    if ! [ "$package" ] ;then
      error 'qemu-static' "doesn't exist for $SYSTEM"
    elif [ "$shasum" = "$(sha512sum $package)" ] ;then
      info 'SHA512SUMS match for qemu-static'
    else
      error SHA512SUMS "don't match for $package"
    fi
    chmod 751 $BUILDDIR/$qemu
  fi

  QEMU_EXECVE="-e QEMU_EXECVE=1 -v $BUILDDIR/$qemu:/usr/bin/$qemu"
fi

# Copy on the build directory
cp -r $DIR/source/$PKG/* $PKGDIR
cp -r $DIR/lib $PKGDIR

docker pull $DARCH/alpine:$DTAG
if $DEV ;then
  info "You're actually on dev mode, you may need to run:
sh lib/main.sh"
  docker run -it --rm $QEMU_EXECVE -v $PKGDIR:$CONTAINERDIR -w $CONTAINERDIR -e PKG=$PKG -e DEV=true $DARCH/alpine:$DTAG $qemu /bin/sh
else
  docker run -it --rm $QEMU_EXECVE -v $PKGDIR:$CONTAINERDIR -w $CONTAINERDIR -e PKG=$PKG $DARCH/alpine:$DTAG $qemu /bin/sh lib/main.sh || true

  package=$(cd $PKGDIR; ls -d ${PKG}_*_${KERNEL}_$ARCH*) || {
    error "build not found" "build directory staying at $PKGDIR"
    exit 1
  }

  if [ "$package" ] && [ -d build/$package ] ;then
     error "$DIR/build/$package" "the file already exist!\
     build staying at $PKGDIR"
     exit 1
  elif [ "$package" ] && mv -n "$PKGDIR/$package" "$DIR/build" ;then
    info "Your build is now at '$DIR/build/$package'"
    rm -rf $PKGDIR
    cd $DIR/build
    sed -i "/.*${PKG}_.*_${KERNEL}_$ARCH.*/d" SHA512SUMS 2>/dev/null
    sha512sum $package >> SHA512SUMS
  else
    error "$PKGDIR/$package" "an error occured when moving  to $DIR/build!\
 Your build is staying at $PKGDIR/$package"
    exit 1
  fi
fi

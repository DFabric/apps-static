#!/bin/sh
set -eu

# Current directory
DIR=$(cd -P $(dirname $0) && pwd)
cd $DIR

mkdir -p build

. lib/env.sh

usage() {
  cat <<EOF
usage: $0 PACKAGE ARCHITECTURES...

Available packages:
$(ls -1 source)

Available architectures:
[x86-64,x86,armhf,arm64] (default: $ARCH)
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
  -h|--help|'') usage 0;;
esac


if [ $(id -u) = 0 ] ;then
  error 'script runned as root' "This could be dangerous. To add yourself to the docker group: usermod -aG docker 'user'"
elif ! docker ps >/dev/null ;then
  error 'no Docker daemon' "not started or not available for $(whoami)"
fi

PKG=$1
TARGET_ARCH=$2
case ${2-} in
  *,*) parsearch $2;;
  aarch64) error 'invalid arch, aarch64' 'do you mean `arm64`?';;
esac

if [ -z "$TARGET_ARCH" ]; then
 TARGET_ARCH=$ARCH
fi

PKGDIR=$BUILDDIR/$PKG/$TARGET_ARCH

# Check build directory
mkdir -p $PKGDIR
#[ "$(ls $PKGDIR 2>/dev/null)" ] && error "$PKGDIR" 'already present, delete it first'
[ -d "source/$PKG" ] || { error "source/$PKG" 'not found.'; }

# No need of Qemu to run x86 on x86-64
info "${TARGET_ARCH} ${ARCH}"
if [ "TARGET_ARCH" = x86 ] && [ "$ARCH" = x86-64 ]; then
  docker_image=i386/alpine:$DTAG

# Only x86_64 can cross-compile - for now
elif [ "TARGET_ARCH" ] && [ "$ARCH" != x86-64 ] && [ "$ARCH" != "TARGET_ARCH" ] ;then
  error "$ARCH" "only x86_64 can cross compile."

# https://github.com/multiarch/alpine
elif [ "TARGET_ARCH" ] && [ "TARGET_ARCH" != "$ARCH" ] ;then
  docker_image=multiarch/alpine:$2-$MATAG
  # configure binfmt-support on the Docker host
  docker pull multiarch/qemu-user-static:register
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
else
  docker_image=alpine:$DTAG
fi

info $docker_image

# Copy to the build directory
cp -r $DIR/source/$PKG/* $PKGDIR
cp -r $DIR/lib $PKGDIR

if [ -d $DIR/build ]; then
mkdir $PKGDIR/local_builds
cp -r $DIR/build/*${TARGET_ARCH}*.tar.xz $PKGDIR/local_builds || :
cp $DIR/build/SHA512SUMS $PKGDIR/local_builds || :
fi

docker pull $docker_image

delete_build() {
  rm -r $PKGDIR
  info "build directory $PKGDIR deleted"
}

docker_args="-it --rm -v $PKGDIR:$CONTAINERDIR -w $CONTAINERDIR -e PKG=$PKG -e TARGET_ARCH=$2"

if $DEV ;then
  info "You're actually on dev mode, you may need to run:
sh lib/main.sh"
  docker run $docker_args -e DEV=true $docker_image /bin/sh
else
  docker run $docker_args -e PKG=$PKG $docker_image /bin/sh lib/main.sh || true

  package=$(cd $PKGDIR; ls -d ${PKG}_*_${TARGET_ARCH}*) || {
    error "$PKGDIR" "build not found"
    delete_build
    exit 1
  }

  if [ "$package" ] && [ -d build/$package ] ;then
    error "$DIR/build/$package" "file already existing"
    delete_build
    exit 1
  elif [ "$package" ] && mv -f "$PKGDIR/$package" "$DIR/build" ;then
    info "Your build is now at '$DIR/build/$package'"
    delete_build
    cd $DIR/build
    touch SHA512SUMS
    sed -i "/.*${PKG}_.*_${KERNEL}_${TARGET_ARCH}\.tar\.xz/d" SHA512SUMS
    sha512sum $package >> SHA512SUMS
    sort -k2 SHA512SUMS -o SHA512SUMS
  else
    error "$PKGDIR/$package" "an error occured when moving to $DIR/build"
    delete_build
    exit 1
  fi
fi

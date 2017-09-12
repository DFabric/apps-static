#!/bin/sh
set -eu

# Loading environment variables
. lib/env.sh

DIR=$PWD

# Clean on exit
# Launch on dev mode if you don't wan't to have the clean
if ! $DEV ;then
  clean() {
    info "Deleting $DIR"
    cd $DIR
    # Clean the build directory
    [ "${PACKAGE-}" ] && [ -f $PACKAGE.tar.xz ] && mv $PACKAGE.tar.xz ..
    rm -rf *
    [ "${PACKAGE-}" ] && [ -f ../$PACKAGE.tar.xz ] && mv ../$PACKAGE.tar.xz .
  }
  trap clean EXIT INT QUIT TERM ABRT
fi

# Libraries
. lib/regexlook.sh
. lib/readyaml.sh

if [ "$(readyaml -f pkg.yml deps static)" ] ;then
  # bring ssl_helper - needed for HTTPS
  apk add --update libressl
  info "Installing static libraries dependencies"
  sha512sums=$(wget -qO- $MIRROR/SHA512SUMS)
  for dep in $(readyaml -f pkg.yml deps static) ;do
    # Download the depencies, listed on SHA512SUMS
    info "Installing $dep"
    package=$(printf '%b' "$sha512sums\n" | grep -o "${dep}_.*_$SYSTEM.tar.xz")
    wget "$MIRROR/$package"
    checksum=$(printf "$sha512sums\n "| grep "$package")
    if [ "$checksum" = "$(sha512sum $package)" ] ;then
      info "SHA512SUMS match for $dep"
    else
      error "SHA512SUMS" "don't match for $package"
    fi
    tar xJf $package
    rm $package
    chown -R 0:0 ${dep}_*_$SYSTEM*
    cp -rf ${dep}_*_$SYSTEM*/* /usr
    rm -rf ${dep}_*_$SYSTEM*
  done
fi

# Alpine dependencies
info "Installing system depencies"
apk add --update $(readyaml -f pkg.yml deps alpine)

[ "${ver-}" ] || ver=$(regexlook -w "$(readyaml -f pkg.yml version regex)" "$(readyaml -f pkg.yml version src)" | head -1)
[ "${ver-}" ] || error 'ver' "no version number returned"

# Create the directory
PKG=${DIR#$BUILDDIR/*}
PACKAGE=${PKG}_${ver}_$SYSTEM
mkdir $PACKAGE

info "Package to build: $PACKAGE"

if ! $DEV ;then
  info "Starting the build of $PACKAGE"

  # Build from the sources
  . ./build.sh

  # Don't keep the root user and group
  cd $DIR
  chown -R 1000:1000 $PACKAGE

  if $COMPRESS && [ -f build/$PACKAGE.tar.xz ] ;then
    error "$DIR/build/$PACKAGE.tar.xz" "the file already exist!"
  elif $COMPRESS ;then
    info "Compressing $PACKAGE..."
    apk add --update xz
    tar cJf $PACKAGE.tar.xz $PACKAGE
    rm -rf "$PACKAGE"
    info "Compressed to $PACKAGE.tar.xz!"
  fi
else
  printf "You're on dev mode, run build.sh? [Y/n] "
  read yn
   case $yn in
     n|N) printf "build.sh not runned.\n";;
     *) . ./build.sh;;
   esac
fi

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
    [ "${PACKAGE-}" ] && [ -f $PACKAGE.tar.bz2 ] && mv $PACKAGE.tar.bz2 ..
    rm -rf *
    [ "${PACKAGE-}" ] && [ -f ../$PACKAGE.tar.bz2 ] && mv ../$PACKAGE.tar.bz2 .
  }
  trap clean EXIT INT QUIT TERM ABRT
fi

# Libraries
. lib/regexlook.sh
. lib/readyaml.sh

if [ "$(readyaml -f pkg.yml deps source)" ] ;then
  # bring ssl_helper - needed for HTTPS
  apk add --update libressl
  info "Installing source dependencies"
  for dep in $(readyaml -f pkg.yml deps source) ;do
    # Download the depencies, listed on SHA512SUMS
    info "Installing $dep"
    wget -qO- $MIRROR/$(wget -qO- $MIRROR/SHA512SUMS | grep -o "${dep}_.*_$KERNEL.$ARCH.*") | tar xjf -
    chown -R 0:0 ${dep}_*_$KERNEL.$ARCH*
    cp -r ${dep}_*_$KERNEL.$ARCH*/* /usr
    rm -r ${dep}_*_$KERNEL.$ARCH*
  done
fi

# Alpine dependencies
info "Installing system depencies"
apk add --update $(readyaml -f pkg.yml deps alpine)

# Get the latest version
[ "${ver-}" ] || ver=$(regexlook -w "$(readyaml -f pkg.yml version regex)" "$(readyaml -f pkg.yml version src)" | head -1)
[ "${ver-}" ] || error 'ver' "no version number returned"

# Create the directory
PKG=${DIR#$BUILDDIR/*}
PACKAGE=${PKG}_${ver}_linux.$ARCH
mkdir $PACKAGE

info "Package to build: $PACKAGE"

if ! $DEV ;then
  info "Starting the build of $PACKAGE"

  # Build from the sources
  . ./build.sh

  # Don't keep the root user and group
  cd $DIR
  chown -R 1000:1000 $PACKAGE

  if $COMPRESS && [ -f build/$PACKAGE.tar.bz2 ] ;then
    error "$DIR/build/$PACKAGE.tar.bz2" "the file already exist!"
  elif $COMPRESS ;then
    info "Compressing $PACKAGE..."
    tar cjf $PACKAGE.tar.bz2 $PACKAGE
    rm -r "$PACKAGE"
    info "Compressed to $PACKAGE.tar.bz2!"
  fi
else
  printf "You're on dev mode, run build.sh? [N/y] "
  read yn
   case $yn in
     y|Y) . ./build.sh;;
     *) printf "build.sh not runned.\n";;
   esac
fi

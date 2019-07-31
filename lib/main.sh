#!/bin/sh
set -eu

# Loading environment variables
. lib/env.sh

DIR=$PWD

# Clean on exit
# Launch on dev mode if you don't wan't to have the clean
if ! $DEV ;then
  clean() {
    info "Deleting $DIR/* on the container"
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



# Alpine dependencies
info 'Installing system depencies'
apk add --update ca-certificates openssl wget $(readyaml -f pkg.yml deps alpine) $([ $COMPRESS ] && printf xz)

if [ "$(readyaml -f pkg.yml deps static)" ] ;then
  info 'Installing static libraries dependencies'
  sha512sums=$(wget -qO- $MIRROR/SHA512SUMS)
  sha512sumsLocal=$(cat local_builds/SHA512SUMS)
  for dep in $(readyaml -f pkg.yml deps static) ;do
    # Download the depencies, listed on SHA512SUMS
    info "Installing $dep"
    match="${dep}*_${TARGET_ARCH}.tar.xz"
   

     info "Checking locally for $match" 
     for f in local_builds/$match; do
     info $f
    ## Check if the glob gets expanded to existing files.
    ## If not, f here will be exactly the pattern above
    ## and the exists test will evaluate to false.
    [ -e "$f" ] && localpackage="$f" 
    ## This is all we needed to know, so we can break after the first iteration
    break
done 

 

    if [ -f "$localpackage" ]; then 
       info "local package found for ${dep} $localpackage"
       package=$localpackage    
   else
    info "local package not found"
    package=$(printf '%b' "$sha512sums\n" | grep -om1 "$match") || error "no package match" "$match"
    wget "$MIRROR/$package" -O $package

    # Verify shasum
    case $(printf "$sha512sums\n "| grep "$package") in
      "$(sha512sum $package)") info "SHA512SUMS match for $dep";;
      *) error "SHA512SUMS" "don't match for $package";;
    esac
  fi
    tar xJf $package
    rm $package    
    chown -R 0:0 ${dep}_*_$TARGET_ARCH*
    cp -rf ${dep}_*_$TARGET_ARCH*/* /usr
    rm -rf ${dep}_*_$TARGET_ARCH*
  done
fi

[ "${ver-}" ] || ver=$(regexlook -w "$(readyaml -f pkg.yml version regex)" "$(readyaml -f pkg.yml version src)" | head -1 | tr - .)
[ "${ver-}" ] || error 'ver' 'no version number returned'

# Create the directory
PACKAGE=${PKG}_${ver}_$TARGET_ARCH
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

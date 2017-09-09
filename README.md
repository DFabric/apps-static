# apps-static

### Portable static applications

#### Static applications, portable across all Linuxes. Builds for x86, x86-64, armv7 and arm64.

## Purpose

- No root permissions needed

- Don't potentially mess up your system - no dependencies

- Commands available for the user if defined in the PATH

- Portable across all Linuxes

## Get the application

You can use the `helper.sh` script that will download and place the application for you in the `~/.local` directory defined in the PATH.

To print the usage and view available packages:

`wget -qO- https://raw.githubusercontent.com/DFabric/apps-static/master/helper.sh | $0 -`

When you have chosen a package, replace `$PACKAGE` and install it locally:

`wget -qO- https://raw.githubusercontent.com/DFabric/apps-static/master/helper.sh $PACKAGE | $0 -`


You can also use `curl -sL` instead of `wget -qO-`


## Manual download

Simply download and extract the archive of the application. The path can be `/usr` or whatever you want.

Replace `${PACKAGE}` by one of the available [here](https://bitbucket.org/dfabric/packages/downloads/)

`wget -qO- https://bitbucket.org/dfabric/packages/downloads/${PACKAGE}.tar.bz2 | tar xjf -`

You can also use `curl -sL` instead of `wget -qO-`

A `$PACKAGE` folder will be created.

The binaries you will need are most likely to be in the `bin` folder, but can be on other location like `sbin` depending of the application/library.

## Building

You will need to have [Docker](https://www.docker.com/) installed. An Alpine Linux image is used for the build environment.

The sources of the build are all available in the `source` directory.

Each program/library have its own `pkg.yml` description file that have:
- the source dependencies (already builded with this tool)
- the Alpine Linux dependencies
- the latest version of it (regex + url)

The `build.sh` list the commands to build the package

Additional files can also be found depending of the needs.


The builds are fully reproducible and their sha512 sums are stored in [SHA512SUMS](https://bitbucket.org/dfabric/packages/downloads/SHA512SUMS)

## Disclaimers

Features and modules can be missing and/or not functioning like expected.

The applications aren't specially developed to become static and portable, this is not for the moment very well tested.

This project is designed to be easily ported to support BSD, Darwin, NT kernels and to be used without Docker.


## License

Copyright (c) 2017 Julien Reichardt - ISC License

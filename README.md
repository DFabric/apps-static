# apps-static

### Standalone portable applications

#### Static applications, portable across all Linuxes. Builds for x86, x86-64, armhf and arm64.

## Purpose

- No root permissions needed

- Using the latest release of an application

- Don't potentially mess up your system - no dependencies

- Portable across all Linuxes

## Get the application

You can use the `helper.sh` script that will download the package in the actual directory.

`wget -qO-` can be replaced by `curl -s`

To list available packages:

`wget -qO- https://raw.githubusercontent.com/DFabric/apps-static/master/helper.sh`

Change `${PACKAGE}` by your chosen package.

To download the `${PACKAGE}` in the current directory:

`sh -c "APP=${PACKAGE} $(wget -qO- https://raw.githubusercontent.com/DFabric/apps-static/master/helper.sh)"`

You can place its subdirectories (e.g. `bin`, `lib`, `share`...) in `/usr/local/` to be reachable globally, or directly use the binnary in `bin`.

## Manual download

Simply download and extract the archive of the application. The path can be `/usr` or whatever you want.

Replace `${PACKAGE}` by one of the available [here](https://bintray.com/dfabric/apps-static/builds#files)

`wget -qO- ${URL_PATH} | tar xJf -`

A `$PACKAGE` folder will be created.

The binaries you will need are likely to be in the `bin` folder, but other locations like `sbin` depending of the application/library.

## Building

You will need to have [Docker](https://www.docker.com/) installed. An Alpine Linux image is used for the build environment.

To build a package:

`./build-static PACKAGE ARCHITECTURES...`

For example:

`./build-static dppm-static x86-64,arm64,armhf`

The sources used for the builds are available in the `source` directory.

Each program/library have its own `pkg.yml` description file that have:
- the source dependencies (already builded with this tool)
- the Alpine Linux dependencies
- the latest version of it (regex + url)

The `build-static.sh` list the commands to build the package

Additional files can also be found depending of the needs.

The builds are reproducible and their hashes are stored in SHA512SUMS.

## Disclaimers

Features and modules can be missing and/or not functioning like expected.

The applications aren't specially developed to become static and portable, this is not for the moment very well tested.

This project is designed to be easily ported to support BSD, Darwin, NT kernels and to be used without Docker.


## License

Copyright (c) 2017-2018 Julien Reichardt - ISC License

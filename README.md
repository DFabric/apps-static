# apps-static

### Portable static applications

#### Static applications, portable accross Linux (even non-GNU) distributions. For now on x86-64. x86, armv7 and arm64 coming soon.

## Get the application

Simply download and extract the archive of the application. The path can be `/usr` or whatever you want.

Replace `${PACKAGE}` by one of the available [here](https://bitbucket.org/dfabric/packages/downloads/)

`wget -qO- https://bitbucket.org/dfabric/packages/downloads/${PACKAGE}.tar.bz2 | tar xjf -`

 or with curl

`curl -sL https://bitbucket.org/dfabric/packages/downloads/${PACKAGE}.tar.bz2 | tar xjf -`

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

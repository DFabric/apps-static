#!/bin/sh

export GOPATH=/tmp
mkdir -p $GOPATH/src/github.com/pingcap
cd $GOPATH/src/github.com/pingcap

# Git is used to have the version in `tidb-server -V`
git clone https://github.com/pingcap/tidb --branch v$ver --depth 1
cd tidb

export LDFLAGS='-extldflags "-static -fuse-ld=bfd"'
make

mkdir $DIR/$PACKAGE/bin
mv bin/tidb-server $DIR/$PACKAGE/bin

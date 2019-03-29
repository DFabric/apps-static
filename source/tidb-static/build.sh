#!/bin/sh

export GOPATH=/tmp
mkdir -p $GOPATH/src/github.com/pingcap
cd $GOPATH/src/github.com/pingcap

wget -qO- https://github.com/pingcap/tidb/archive/v$ver.tar.gz | tar xzf -
mv tidb-* tidb
cd tidb
rm go.sum

export LDFLAGS='-extldflags -static'
make

mkdir $DIR/$PACKAGE/bin
mv $GOPATH/bin/tidb-server $DIR/$PACKAGE/bin

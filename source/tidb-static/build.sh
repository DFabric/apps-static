#!/bin/sh

mkdir -p /tmp/src/github.com/pingcap
cd /tmp/src/github.com/pingcap

wget -qO- https://github.com/pingcap/tidb/archive/v$ver.tar.gz | tar xzf -
mv tidb-* tidb
cd tidb

make GOPATH=/tmp LDFLAGS='-linkmode external -extldflags "-static"'
strip bin/tidb-server

mkdir $DIR/$PACKAGE/bin
mv bin/tidb-server $DIR/$PACKAGE/bin

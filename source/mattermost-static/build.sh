#!/bin/sh

export GOPATH=/tmp
mkdir -p $GOPATH/src/github.com/mattermost
cd $GOPATH/src/github.com/mattermost

wget -qO- https://github.com/mattermost/mattermost-webapp/archive/v$ver.tar.gz | tar xzf -
mv mattermost-webapp* mattermost-webapp
cd mattermost-webapp
npm install
cd node_modules/mattermost-redux
npm install
npm run build
cd ../..
npm run build

cd ..
go get -u github.com/golang/dep/cmd/dep
wget -qO- https://github.com/mattermost/mattermost-server/archive/v$ver.tar.gz | tar xzf -
mv mattermost-server* mattermost-server

cd mattermost-server
$GOPATH/bin/dep ensure
export LDFLAGS='-extldflags -static'
make build
cp config/default.json config/config.json
make package

rm -f dist/mattermost/bin/platform
mv dist/mattermost $DIR/$PACKAGE

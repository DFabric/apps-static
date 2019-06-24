#!/bin/sh

export GOPATH=/tmp
mattermost_path=$GOPATH/src/github.com/mattermost

mkdir -p $mattermost_path
cd $mattermost_path

wget -qO- https://github.com/mattermost/mattermost-webapp/archive/v$ver.tar.gz | tar xzf -
mv mattermost-webapp* mattermost-webapp
cd mattermost-webapp
npm install
cd node_modules/mattermost-redux
npm install || true
npm run build
cd ../..
npm run build

cd $mattermost_path
wget -qO- https://github.com/mattermost/mattermost-server/archive/v$ver.tar.gz | tar xzf -
mv mattermost-server* mattermost-server

export GO111MODULE=on
export LDFLAGS='-extldflags -static'
cd mattermost-server
make build
cp config/default.json config/config.json
make package

rm -f dist/mattermost/bin/platform
mv dist/mattermost $DIR/$PACKAGE

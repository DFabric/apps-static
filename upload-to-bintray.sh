#!/bin/sh -eu

# Script to upload artifacts to Bintray

BINTRAY_USER_API_KEY=$1
BINTRAY_ORG=dfabric/apps-static
BINTRAY_PACKAGE=builds
BINTRAY_VERSION=latest

BINTRAY_CONTENT_API=https://api.bintray.com/content/$BINTRAY_ORG
BINTRAY_CONTENT_API_PACKAGE=$BINTRAY_CONTENT_API/$BINTRAY_PACKAGE/$BINTRAY_VERSION

for package_path in build/*; do
  package_name=${package_path##*/}
  printf "delete $package_name\n"
  curl -u$BINTRAY_USER_API_KEY -X DELETE $BINTRAY_CONTENT_API/$package_name
  printf "\npost $package_name\n"
  curl -u$BINTRAY_USER_API_KEY -T $package_path $BINTRAY_CONTENT_API_PACKAGE/$package_name
  printf "\n\n"
done

printf "publish to $BINTRAY_CONTENT_API_PACKAGE\n"
curl -u$BINTRAY_USER_API_KEY -X POST $BINTRAY_CONTENT_API_PACKAGE/publish

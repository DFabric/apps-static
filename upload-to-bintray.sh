#!/bin/sh -eu

# Script to upload artifacts to Bintray

BINTRAY_USER_API_KEY=$1
BINTRAY_ORG=https://api.bintray.com/content/dfabric/apps-static
BINTRAY_REPO=builds/latest/

for package_path in build/*; do
  package_name=${package_path##*/}
  printf "delete $package_name\n"
  curl -u$BINTRAY_USER_API_KEY -X DELETE $BINTRAY_ORG/$package_name
  printf "\npost $package_name\n"
  curl -u$BINTRAY_USER_API_KEY -T $package_path $BINTRAY_ORG/$BINTRAY_REPO/$package_name
  printf "\n\n"
done

printf "publish to $BINTRAY_ORG/$BINTRAY_REPO\n"
curl -u$BINTRAY_USER_API_KEY -X POST $BINTRAY_ORG/$BINTRAY_REPO/publish

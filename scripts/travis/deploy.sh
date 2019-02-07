#!/bin/bash
set -ev
echo "PREPARING DEPLOYMENT"

# if [ "${TRAVIS_PULL_REQUEST}" == "false" ] && ([ "${TRAVIS_BRANCH}" == "staging-deployment" ] ; then
MIX_ENV=prod mix do compile, release
mkdir release
mkdir release/content
mkdir release/scripts
cp _build/prod/rel/gameinn/releases/*/app.tar.gz release/content/app.tar.gz
cp appspec.yml release/appspec.yml
cp -a scripts/. release/scripts/
cd release
tar  --owner=1000 --group=1000 -zcvf ../gameinn.tar.gz .
cd ..
# fi

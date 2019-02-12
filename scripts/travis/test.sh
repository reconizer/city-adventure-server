#!/bin/bash
set -ev
cp apps/infrastructure/config/travis.exs apps/infrastructure/config/test.exs

mix ecto.migrate -r Infrastructure.Repository
mix test
echo "Re-running tests for each app" ; for app in apps/**; do cd $app && mix test; cd ../.. ; done

if [ "${TRAVIS_PULL_REQUEST}" == "false" ] && ([ "${TRAVIS_BRANCH}" == "staging-deployment" ]) ; then
  mix docs
  aws s3 cp doc s3://gameinn-docs/ --recursive
fi

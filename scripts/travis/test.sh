#!/bin/bash
set -ev
cp apps/infrastructure/config/travis.exs apps/infrastructure/config/test.exs

MIX_ENV=test mix ecto.migrate -r Infrastructure.Repository
MIX_ENV=test mix test

if [ "${TRAVIS_PULL_REQUEST}" == "false" ] && ([ "${TRAVIS_BRANCH}" == "staging-deployment" ]) ; then
  MIX_ENV=test mix docs
  aws s3 cp doc s3://gameinn-docs/ --recursive
fi

#!/bin/bash

set -eu

export digest=$(cat ./lnd-sidecar-image/digest)
export ref=$(cat ./lnd-sidecar-image-def/.git/short_ref)

pushd charts-repo

yq -i e '.sidecarImage.digest = strenv(digest)' ./charts/lnd/values.yaml
yq -i e '.sidecarImage.git_ref = strenv(ref)' ./charts/lnd/values.yaml

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "bot@galoy.io"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "CI Bot"
fi

(
  cd $(git rev-parse --show-toplevel)
  git merge --no-edit ${BRANCH}
  git add -A
  git status
  git commit -m "chore(deps): bump lnd sidecar image to '${digest}'"
)

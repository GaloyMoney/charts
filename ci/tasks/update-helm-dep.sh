#!/bin/bash

VERSION=$(cat helm-resource/version)

pushd charts-repo/charts/$DIR

yq -i "(.dependencies[] | select(.name == "$DEP") | .version) = \"$VERSION\"" Chart.yaml

helm dependency update

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "bot@galoy.io"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "CI Bot"
fi

(cd $(git rev-parse --show-toplevel)
git merge --no-edit ${BRANCH}
git add -A
git status
git commit -m "chore(deps): update $DEP helm chart in $DIR"
)

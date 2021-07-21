#!/bin/bash

cd galoy-deployments

make bump-chart CHART=${CHART} REF=$(cat ../chart/.git/ref)
make vendir

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
git commit -m "$1"
)

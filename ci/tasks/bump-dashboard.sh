#!/bin/bash

set -eu

pushd chart

repo_ref=$(yq e ".image.git_ref" charts/${CHART}/values.yml )

if [[ $repo_ref == "null" ]]; then
  repo_ref=$(yq e ".${CHART}.image.git_ref" charts/${CHART}/values.yml )
fi

popd

pushd $REPO
git checkout --force ${repo_ref}
REF=$(git rev-parse HEAD) # Fetch the complete ref
popd

cd galoy-deployments

make bump-vendored-ref DEP=${REPO} REF=${REF}
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
git commit -m "Bump ${CHART}'s grafana dashboard to '${REF}'"
)

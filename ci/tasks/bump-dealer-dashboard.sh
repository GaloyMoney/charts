#!/bin/bash

set -eu

pushd chart
repo_ref=$(yq e ".dealer.image.git_ref" charts/dealer/values.yaml )
popd

pushd galoy-deployments
cat > github.key <<EOF
${GITHUB_SSH_KEY}
EOF
# Last ref that changed dashboard
last_ref=$(cat modules/services/addons/vendor/dealer/dashboards/git-ref/ref)
popd

pushd $REPO

# Check if dashboard files have changed between last vendir ref and now
if ! git diff --name-only ${last_ref} ${repo_ref} | grep "grafana/provisioning/dashboards"; then
  exit 0
fi

git checkout --force ${repo_ref}
REF=$(git rev-parse HEAD) # Fetch the complete ref

popd

cd galoy-deployments

make bump-vendored-ref DEP=${REPO} REF=${REF}
GITHUB_SSH_KEY_BASE64=$(base64 -w 0 ./github.key) make vendir

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
git commit -m "chore: bump ${CHART}'s grafana dashboard to '${REF}'"
)

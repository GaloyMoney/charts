#!/bin/bash

set -eu

pushd charts-repo

cat <<EOF >> ../body.md
This PR updates Helm Chart Dependencies.
EOF

gh pr close ${BOT_BRANCH} || true
gh pr create \
  --title "chore(deps): update $DEP helm chart in $DIR" \
  --body-file ../body.md \
  --base ${BRANCH} \
  --head ${BOT_BRANCH} \
  --label galoybot \
  --label helm || true

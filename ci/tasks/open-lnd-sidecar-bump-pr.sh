#!/bin/bash

set -eu

digest=$(cat ./lnd-sidecar-image/digest)

pushd charts-repo

ref=$(yq e '.sidecarImage.git_ref' charts/lnd/values.yaml)
git checkout ${BRANCH}
old_ref=$(yq e '.sidecarImage.git_ref' charts/lnd/values.yaml)

cat <<EOF >> ../body.md
# Bump lnd sidecar image

The lnd sidecar image will be bumped to digest:
\`\`\`
${digest}
\`\`\`

Code diff contained in this image:

https://github.com/GaloyMoney/charts/compare/${old_ref}...${ref}
EOF

gh pr close ${BOT_BRANCH} || true
gh pr create \
  --title "chore(deps): bump-lnd-sidecar-image-${ref}" \
  --body-file ../body.md \
  --base ${BRANCH} \
  --head ${BOT_BRANCH} \
  --label galoybot \
  --label lnd

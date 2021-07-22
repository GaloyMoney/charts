#!/bin/bash

set -eu

cp -r pipeline-tasks/ci/testflight/${CHART} testflight/${CHART}
cp -r repo/charts/${CHART} testflight/${CHART}/chart

if [[ "${CHART}" == "lnd" ]]; then
  pushd testflight/${CHART}/chart
  helm repo add https://charts.bitnami.com/bitnami
  helm dependency build
  popd
fi

cat <<EOF > testflight/${CHART}/terraform.tfvars
testflight_namespace = "${CHART}-testflight-$(cat repo/.git/short_ref)"
EOF

cat <<EOF > testflight/env_name
${CHART}-testflight-$(cat repo/.git/short_ref)
EOF

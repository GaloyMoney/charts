#!/bin/bash

set -eu

cp -r repo/charts/${CHART} testflight/${CHART}/chart
cp -r pipeline-tasks/ci/testflight/${CHART} testflight/${CHART}

pushd testflight/${CHART}/
helm dependency build
popd

cat <<EOF > testflight/${CHART}/terraform.tfvars
testflight_namespace = "${CHART}-testflight-$(cat repo/.git/short_ref)"
EOF

cat <<EOF > testflight/env_name
${CHART}-testflight-$(cat repo/.git/short_ref)
EOF

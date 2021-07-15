#!/bin/bash

cp -r pipeline-tasks/ci/testflight/bitcoind testflight/bitcoind
cp -r repo/charts/bitcoind testflight/bitcoind/chart

cat <<EOF > testflight/bitcoind/terraform.tfvars
testflight_namespace = "testflight-$(cat repo/.git/short_ref)"
EOF

cat <<EOF > testflight/env_name
testflight-$(cat repo/.git/short_ref)
EOF

#!/bin/bash

set -eu

mkdir -p .kube
export KUBECONFIG=$(pwd)/.kube/config
echo ${SMOKETEST_KUBECONFIG} | base64 --decode > ${KUBECONFIG}

kubectl get secret ${SMOKETEST_SECRET:-$(cat testflight/env_name)} -o json \
  | jq -r '.data' > smoketest-settings/data.json

cat <<EOF > smoketest-settings/helpers.sh
function setting() {
  cat smoketest-settings/data.json | jq -r ".\$1" | base64 --decode
}
EOF

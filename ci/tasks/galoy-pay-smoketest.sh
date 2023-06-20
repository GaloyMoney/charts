#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

hosts=`setting "galoy_pay_endpoints"`
port=`setting "galoy_pay_port"`

set +e
for host in $(echo $hosts | jq -r '.[]'); do
  for i in {1..15}; do
    echo "Attempt ${i} to curl galoy pay"
    curl --location -f ${host}:${port}
    if [[ $? == 0 ]]; then success="true"; break; fi;
    sleep 1
  done
done
set -e

set +e
for host in $(echo $hosts | jq -r '.[]'); do
  for i in {1..15}; do
    echo "Attempt ${i} to curl lnurlp endpoint"
    response=$(curl --location -fs ${host}/.well-known/lnurlp/test)
    is_response_valid=$(echo $response | jq -r 'has("callback") and has("minSendable") and has("maxSendable") and has("metadata") and has("tag")')
    if [[ "$is_response_valid" == "true" ]]; then success="true"; break; fi;
    sleep 1
  done
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=$(setting "mempool_endpoint")
port=$(setting "mempool_port")

set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl mempool"
  curl -sSf ${host}:${port}/api/v1/fees/recommended | grep -P '"fastestFee":.*"halfHourFee":.*"hourFee":.*"economyFee":.*"minimumFee":'
  if [[ $? == 0 ]]; then
    success="true"
    break
  fi
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi

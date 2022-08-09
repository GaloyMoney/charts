#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

price_host=`setting "price_server_grpc_host"`
price_port=`setting "price_server_grpc_port"`
export PRICE_SERVER_URL="http://${price_host}:${price_port}"

set +e
for i in {1..15}; do
  echo "Attempt ${i} to get a quote"
  stablesats price 100000000
  if [[ $? == 0 ]]; then success="true"; break; fi;
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

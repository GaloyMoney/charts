#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=`setting "api_dashboard_endpoint"`
port=`setting "api_dashboard_port"`

set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl api dashboard"
  curl --location -f ${host}:${port}
  if [[ $? == 0 ]]; then success="true"; break; fi;
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

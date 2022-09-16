#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=`setting "specter_endpoint"`
port=`setting "specter_port"`

set +e
for i in {1..15}; do
  echo "Attempt ${i} to curl specter"
  curl -f ${host}:${port} | grep direct # Check if we are being redirected
  if [[ $? == 0 ]]; then success="true"; break; fi;
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

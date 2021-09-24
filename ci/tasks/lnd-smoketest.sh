#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=`setting "lndmon_endpoint"`

set +e
for i in {1..60}; do
  echo "Attempt ${i} to curl lndmon"
  curl ${host}:9092/metrics
  if [[ $? == 0 ]]; then success="true"; break; fi;
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

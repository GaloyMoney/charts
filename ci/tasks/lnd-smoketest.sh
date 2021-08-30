#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
lndmonHost=lnd-lndmon.${namespace}.svc.cluster.local
loopHost=lnd-loop.${namespace}.svc.cluster.local

set +e
for i in {1..60}; do
  echo "Attempt ${i} to curl lndmon and loop"
  curl ${lndmonHost}:9092/metrics
  if [[ $? != 0 ]]; then continue; fi;
  curl ${loopHost}:8081/v1/auto/suggest
  if [[ $? == 0 ]]; then success="true"; break; fi;
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
host=${HOST:-specter.${namespace}.svc.cluster.local}

set +e
for i in {1..60}; do
  echo "Attempt ${i} to curl specter"
  curl ${host}:25441
  if [[ $? == 0 ]]; then success="true"; break; fi;
  sleep 1
done
set -e

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

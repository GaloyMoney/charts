#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
host=lnd-lndmon.${namespace}.svc.cluster.local

curl ${host}:9092/metrics

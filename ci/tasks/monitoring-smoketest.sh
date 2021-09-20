#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
host=${namespace}-prometheus-alertmanager.${namespace}.svc.cluster.local

curl ${host}/-/healthy

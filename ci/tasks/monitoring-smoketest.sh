#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
alertmanager_dns=${ALERTMANAGER_DNS:-"${namespace}-prometheus-alertmanager"}
host=${alertmanager_dns}.${namespace}.svc.cluster.local

curl ${host}/-/healthy

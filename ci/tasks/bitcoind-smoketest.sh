#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
host=bitcoind.${namespace}.svc.cluster.local
bitcoin-cli -version
bitcoin-cli -testnet \
  -rpcuser=rpcuser \
  -rpcpassword=${BITCOIND_RPCPASSWORD} \
  -rpcport=18332 \
  -rpcconnect=${host}\
  -getinfo

curl ${host}:3000/metrics

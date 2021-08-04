#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
host=bitcoind.${namespace}.svc.cluster.local
bitcoin-cli -version
bitcoin-cli -testnet \
  -rpcuser=rpcuser \
  -rpcpassword=${BITCOIND_RPCPASSWORD} \
  -rpcport=${BITCOIND_RPCPORT} \
  -rpcconnect=${host}\
  -getinfo

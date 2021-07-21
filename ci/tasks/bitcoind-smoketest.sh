#!/bin/bash

set -eu

namespace=${NAMESPACE:-$(cat testflight/env_name)}
bitcoin-cli -version
bitcoin-cli -testnet \
  -rpcuser=rpcuser \
  -rpcpassword=${BITCOIND_RPCPASSWORD} \
  -rpcport=${BITCOIND_RPCPORT} \
  -rpcconnect=bitcoind.${namespace}.svc.cluster.local \
  -getinfo

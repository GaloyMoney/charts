#!/bin/bash

bitcoin-cli -version
bitcoin-cli -testnet \
  -rpcuser=rpcuser \
  -rpcpassword=${BITCOIN_RPCPASSWORD} \
  -rpcport=18332 \
  -rpcconnect=bitcoind.$(cat testflight/env_name).svc.cluster.local \
  -getinfo

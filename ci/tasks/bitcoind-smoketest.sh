#!/bin/bash

bitcoin-cli -version
bitcoin-cli -testnet \
  -rpcuser=rpcuser \
  -rpcpassword=rpcpassword \
  -rpcport=18332 \
  -rpcconnect=bitcoind.$(cat testflight/env_name).svc.cluster.local \
  -getinfo

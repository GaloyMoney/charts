#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

host=`setting "bitcoind_endpoint"`
bitcoin-cli -version
bitcoin-cli -${1:-signet} \
  -rpcuser=`setting "bitcoind_user"` \
  -rpcpassword=`setting "bitcoind_rpcpassword"` \
  -rpcport=`setting "bitcoind_port"` \
  -rpcconnect=${host}\
  -getinfo

curl ${host}:3000/metrics

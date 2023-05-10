#!/bin/sh

kubectl -n galoy-dev-bitcoin exec bitcoind-0 -- bitcoin-cli generatetoaddress 1 bcrt1qxcpz7ytf3nwlhjay4n04nuz8jyg3hl4ud02t9t
kubectl -n galoy-dev-bitcoin exec bitcoind-onchain-0 -- bitcoin-cli generatetoaddress 1 bcrt1qxcpz7ytf3nwlhjay4n04nuz8jyg3hl4ud02t9t

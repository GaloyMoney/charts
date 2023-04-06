#!/bin/sh

kubectl -n "$1" exec bitcoind-0 -- bitcoin-cli generatetoaddress 1 bcrt1qxcpz7ytf3nwlhjay4n04nuz8jyg3hl4ud02t9t

#!/bin/sh

kubectl -n galoy-dev-bitcoin exec lnd1-0 -c lnd -- lncli -n regtest getinfo 2> /dev/null
while [[ $? != 0 ]]
do 
  sleep 1
  kubectl -n galoy-dev-bitcoin exec lnd1-0 -c lnd -- lncli -n regtest getinfo 2> /dev/null
done
kubectl -n galoy-dev-bitcoin exec bitcoind-0 -- bitcoin-cli generatetoaddress 1 bcrt1qxcpz7ytf3nwlhjay4n04nuz8jyg3hl4ud02t9t

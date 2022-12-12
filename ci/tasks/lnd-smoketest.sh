#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

lnd_api_host=$(setting "lnd_api_endpoint")
lnd_p2p_host=$(setting "lnd_p2p_endpoint")

if [ "${lnd_api_host}" != "" ]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect the lnd_api_endpoint"
    nc -zv ${lnd_api_host} 10009
    if [ $? = 0 ]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [ "$success" != "true" ]; then echo "Could not connect to the lnd_api_endpoint" && exit 1; fi;
fi

if [ "${lnd_p2p_host}" != "" ]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect the lnd_p2p_endpoint"
    nc -zv ${lnd_p2p_host} 9735
    if [ $? = 0 ]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [ "$success" != "true" ]; then echo "Could not connect to the lnd_p2p_endpoint" && exit 1; fi;
fi

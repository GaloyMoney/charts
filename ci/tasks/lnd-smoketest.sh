#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

lnd_host=`setting "lnd_p2p_endpoint"`

if [[ "${lnd_host}" != "" ]]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect the lnd_p2p_endpoint"
    nc -zv ${lnd_host} 9735
    if [[ $? == 0 ]]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;
fi

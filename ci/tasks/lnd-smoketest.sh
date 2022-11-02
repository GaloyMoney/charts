#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

lndmon_host=`setting "lndmon_endpoint"`
lnd_host=`setting "lnd_p2p_endpoint"`

if [[ "${lndmon_host}" != ""]]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to curl lndmon"
    curl -f ${lndmon_host}:9092/metrics
    if [[ $? == 0 ]]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;
fi

nc -zv ${lnd_host} 9735

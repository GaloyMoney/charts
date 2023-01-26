#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

fulcrum_api_host=$(setting "fulcrum_endpoint")
fulcrum_stats_port=$(setting "fulcrum_stats_port")

if [ "${fulcrum_api_host}" != "" ]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect to the fulcrum_stats_port"
    curl -f ${fulcrum_api_host}:${fulcrum_stats_port}/stats
    if [ $? = 0 ]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [ "$success" != "true" ]; then echo "Could not connect to the fulcrum_stats_port" && exit 1; fi;
fi

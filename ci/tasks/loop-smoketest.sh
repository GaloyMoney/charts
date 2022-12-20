#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

loop_api_host=$(setting "loop_api_endpoint")

if [ "${loop_api_host}" != "" ]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect the GRPC loop_api_endpoint"
    nc -zv ${loop_api_host} 11010
    if [ $? = 0 ]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [ "$success" != "true" ]; then echo "Could not connect to the GRPC loop_api_endpoint" && exit 1; fi;
fi

if [ "${loop_p2p_host}" != "" ]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect the REST loop_api_endpoint"
    nc -zv ${loop_p2p_host} 8081
    if [ $? = 0 ]; then success="true"; break; fi;
      sleep 1
    done
    set -e

    if [ "$success" != "true" ]; then echo "Could not connect to the REST loop_api_endpoint" && exit 1; fi;
fi

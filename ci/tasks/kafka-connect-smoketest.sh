#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

kafka_connect_api_host=$(setting "kafka_connect_api_host")
kafka_connect_api_port=$(setting "kafka_connect_api_port")

if [ "${kafka_connect_api_host}" != "" ]; then
  set +e
  for i in {1..60}; do
    echo "Attempt ${i} to connect to http://${kafka_connect_api_host}:${kafka_connect_api_port}"
    curl -sSf http://${kafka_connect_api_host}:${kafka_connect_api_port}/connector-plugins
    if [ $? = 0 ]; then
      success="true"
      break
    fi
    sleep 1
  done
  set -e

  if [ "$success" != "true" ]; then echo "Could not connect to http://${kafka_connect_api_host}:${kafka_connect_api_port}" && exit 1; fi
fi

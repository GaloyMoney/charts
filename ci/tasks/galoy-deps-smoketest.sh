#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

kafka_broker_host=`setting "kafka_broker_endpoint"`
kafka_broker_port=`setting "kafka_broker_port"`
kafka_topic=`setting "kafka_topic"`


msg="kafka message"
set +e
for i in {1..15}; do
  echo "Attempt ${i} to produce and consume from kafka"
  echo $msg | kafkacat -P -b $kafka_broker_host:$kafka_broker_port -t $kafka_topic
  consumed_message=$(kafkacat -C -b $kafka_broker_host:$kafka_broker_port -t $kafka_topic -e)
  if [[ "$consumed_message" == "$msg" ]]; then success="true"; break; fi;
  sleep 1
done

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

set -e

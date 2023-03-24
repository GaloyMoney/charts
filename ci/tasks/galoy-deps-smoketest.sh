#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

kafka_broker_host=`setting "kafka_broker_endpoint"`
kafka_broker_port=`setting "kafka_broker_port"`
kafka_topic=`setting "smoketest_topic"`
kafka_service_name_prefix="kafka-kafka-plain"
setting "smoketest_kubeconfig" | base64 --decode > kubeconfig.json
export KUBECONFIG=$(pwd)/kubeconfig.json

cat <<EOF > topic.tf
provider "kafka" {
  bootstrap_servers = [
    "${kafka_service_name_prefix}-0:9092",
    "${kafka_service_name_prefix}-1:9092",
    "${kafka_service_name_prefix}-2:9092"
  ]
}

terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
}

resource "kafka_topic" "smoketest_topic" {
   name               = "${kafka_topic}"
   replication_factor = 3
   partitions         = 3
}
EOF
terraform init
terraform apply -auto-approve

msg="kafka message"
set +e
for i in {1..15}; do
  echo "Attempt ${i} to produce and consume from kafka"
  echo $msg | kafkacat -P -b $kafka_broker_host:$kafka_broker_port -t $kafka_topic
  consumed_message=$(kafkacat -C -b $kafka_broker_host:$kafka_broker_port -t $kafka_topic -e)
  if [[ "$consumed_message" == "$msg" ]]; then success="true"; break; fi;
  sleep 1
done

terraform destroy -auto-approve

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

set -e

#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

kafka_broker_host=`setting "kafka_broker_endpoint"`
kafka_broker_port=`setting "kafka_broker_port"`
kafka_topic="smoketest-topic"
kafka_cluster=`setting "kafka_cluster"`
kafka_namespace=`setting "kafka_namespace"`
setting "smoketest_kubeconfig" | base64 --decode > kubeconfig.json
export KUBECONFIG=$(pwd)/kubeconfig.json

cat << EOF > topic.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: $kafka_topic
  labels:
    strimzi.io/cluster: $kafka_cluster
spec:
  partitions: 3
  replicas: 3
EOF

# Clean kafka topic if already exists, could be leftover from previous failed jobs
kubectl -n $kafka_namespace delete kafkatopics.kafka.strimzi.io $kafka_topic || true
kubectl -n $kafka_namespace apply -f topic.yaml

msg="kafka message"
set +e
for i in {1..15}; do
  echo "Attempt ${i} to produce and consume from kafka"
  echo $msg | kafkacat -P -b $kafka_broker_host:$kafka_broker_port -t $kafka_topic
  consumed_message=$(kafkacat -C -b $kafka_broker_host:$kafka_broker_port -t $kafka_topic -e)
  if [[ "$consumed_message" == "$msg" ]]; then success="true"; break; fi;
  sleep 1
done

kubectl -n $kafka_namespace delete kafkatopics.kafka.strimzi.io $kafka_topic

if [[ "$success" != "true" ]]; then echo "Smoke test failed" && exit 1; fi;

set -e

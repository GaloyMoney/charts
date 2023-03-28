#!/bin/bash

NAMESPACE="galoy-dev-kafka"
KAFKA_POD_NAME="kafka-kafka-0"
BOOTSTRAP_SERVER="kafka-kafka-plain-bootstrap:9092"

while read -r topic; do
  echo "Deleting topic: $topic"
  kubectl -n $NAMESPACE exec $KAFKA_POD_NAME -- bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --delete --topic "$topic"
done < topics_to_delete.txt

echo "All topics have been deleted."

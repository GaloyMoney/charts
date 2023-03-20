#!/bin/bash

# no underlines are supported
topics=(
  "mongodb-accounts"
  "mongodb-changelog"
  "mongodb-dbmetadatas"
  "mongodb-invoiceusers"
  "mongodb-lnpayments"
  "mongodb-medici-balances"
  "mongodb-medici-journals"
  "mongodb-medici-locks"
  "mongodb-medici-transaction-metadatas"
  "mongodb-medici-transactions"
  "mongodb-payment-flow-states"
)

for topic in "${topics[@]}"; do
  cat > "kafka-topic-${topic}.yaml" << EOL
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: $topic
  namespace: galoy-dev-kafka
  labels:
    strimzi.io/cluster: kafka
spec:
  partitions: 1
  replicas: 3
  config:
    retention.ms: 7200000
    segment.bytes: 1073741824
    min.insync.replicas: 2
EOL
done

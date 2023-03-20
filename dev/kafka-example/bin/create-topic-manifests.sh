#!/bin/bash

topics=(
  "mongodb-accounts"
  "mongodb-changelog"
  "mongodb-dbmetadatas"
  "mongodb-invoiceusers"
  "mongodb-lnpayments"
  "mongodb-medici_balances"
  "mongodb-medici_journals"
  "mongodb-medici_locks"
  "mongodb-medici_transaction_metadatas"
  "mongodb-medici_transactions"
  "mongodb-payment_flow_states"
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

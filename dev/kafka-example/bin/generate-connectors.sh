#!/bin/bash

collections=("medici_balances" "medici_journals" "medici_locks" "medici_transaction_metadatas" "medici_transactions")
terraform_file="kafka_source_mongo.tf"

echo "" > "$terraform_file"

for collection in "${collections[@]}"; do
  filename="kafka-source-mongo-${collection//_/-}.yaml"
  cat > "$filename" << EOL
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaConnector
metadata:
  name: kafka-source-mongo-${collection//_/-}
  namespace: galoy-dev-kafka
  labels:
    strimzi.io/cluster: kafka
spec:
  class: com.mongodb.kafka.connect.MongoSourceConnector
  tasksMax: 1
  config:
    startup.mode: copy_existing
    connection.uri: mongodb://testGaloy:password@galoy-mongodb-headless.galoy-dev-galoy.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0
    topic.prefix: mongodb
    database: galoy
    topic.separator: "_"
    collection: $collection
EOL

  cat >> "$terraform_file" << EOL
resource "kubernetes_manifest" "kafka_source_mongo_${collection//_/-}" {
  manifest = yamldecode(file("\${path.module}/${filename}"))
}

EOL
done

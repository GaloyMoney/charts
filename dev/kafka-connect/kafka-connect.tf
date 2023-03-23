## CONNECT
resource "kubernetes_manifest" "kafka_connect" {
  manifest = yamldecode(file("${path.module}/kafka-connect.yaml"))
}

## SOURCE CONNECTORS
resource "kubernetes_manifest" "kafka_source_mongo_medici-balances" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo-medici-balances.yaml"))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-journals" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo-medici-journals.yaml"))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-locks" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo-medici-locks.yaml"))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-transaction-metadatas" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo-medici-transaction-metadatas.yaml"))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-transactions" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo-medici-transactions.yaml"))
}

## TOPICS BY THE TERRAFORM PROVIDER
data "external" "kafka_bootstrap_ip" {
  program = ["${path.module}/bin/get_kafka_bootstrap_ip.sh"]
}

data "external" "kafka_bootstrap_nodeport" {
  program = ["${path.module}/bin/get_kafka_bootstrap_nodeport.sh"]
}

provider "kafka" {
  bootstrap_servers = ["${lookup(data.external.kafka_bootstrap_ip.result, "result")}:${lookup(data.external.kafka_bootstrap_nodeport.result, "result")}"]
  tls_enabled       = false
}

resource "kafka_topic" "mongodb_galoy_medici_balances" {
  name               = "mongodb_galoy_medici_balances"
  partitions         = 1
  replication_factor = 3
}

resource "kafka_topic" "mongodb_galoy_medici_journals" {
  name               = "mongodb_galoy_medici_journals"
  partitions         = 1
  replication_factor = 3
}

resource "kafka_topic" "mongodb_galoy_medici_locks" {
  name               = "mongodb_galoy_medici_locks"
  partitions         = 1
  replication_factor = 3
}

resource "kafka_topic" "mongodb_galoy_medici_transaction_metadatas" {
  name               = "mongodb_galoy_medici_transaction_metadatas"
  partitions         = 1
  replication_factor = 3
}

resource "kafka_topic" "mongodb_galoy_medici_transactions" {
  name               = "mongodb_galoy_medici_transactions"
  partitions         = 1
  replication_factor = 3
}

terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
}

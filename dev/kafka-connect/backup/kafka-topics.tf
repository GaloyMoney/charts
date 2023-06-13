terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
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

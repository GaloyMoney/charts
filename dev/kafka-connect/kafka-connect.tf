resource "kubernetes_manifest" "kafka_connect" {
  manifest = yamldecode(file("${path.module}/kafka-connect.yaml"))
}

resource "kubernetes_manifest" "kafka_source_mongo" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo.yaml"))
}

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

resource "kafka_topic" "mongodb-accounts" {
  name               = "mongodb-accounts"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-changelog" {
  name               = "mongodb-changelog"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-dbmetadatas" {
  name               = "mongodb-dbmetadatas"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-invoiceusers" {
  name               = "mongodb-invoiceusers"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-lnpayments" {
  name               = "mongodb-lnpayments"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-medici-balances" {
  name               = "mongodb-medici-balances"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-medici-journals" {
  name               = "mongodb-medici-journals"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-medici-locks" {
  name               = "mongodb-medici-locks"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-medici-transaction-metadatas" {
  name               = "mongodb-medici-transaction-metadatas"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-medici-transactions" {
  name               = "mongodb-medici-transactions"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

resource "kafka_topic" "mongodb-payment-flow-states" {
  name               = "mongodb-payment-flow-states"
  partitions         = 1
  replication_factor = 3
  config = {
    "retention.ms"        = "7200000"
    "segment.bytes"       = "1073741824"
    "min.insync.replicas" = "2"
  }
}

terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
}

variable "name_prefix" {}

locals {
  kafka_namespace        = "${var.name_prefix}-kafka"
  galoy_namespace        = "${var.name_prefix}-galoy"
  mongodb_password       = "password" # data.kubernetes_secret.mongodb_creds.data["mongodb-password"]
  mongodb_connection_uri = "mongodb://testGaloy:${local.mongodb_password}@galoy-mongodb-headless.${local.galoy_namespace}.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0"
}


## CONNECT
resource "kubernetes_manifest" "kafka_connect" {
  manifest = yamldecode(file("${path.module}/kafka-connect.yaml"))
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

## SOURCE CONNECTORS
resource "kubernetes_manifest" "kafka_source_mongo_medici-balances" {
  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-balances.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-journals" {
  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-journals.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-locks" {
  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-locks.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-transaction-metadatas" {
  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-transaction-metadatas.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
}

resource "kubernetes_manifest" "kafka_source_mongo_medici-transactions" {
  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-transactions.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
}

## SINK CONNECTOR
## to use the sink connector locally
## run: gcloud auth application-default login to create th file ~/.config/gcloud/application_default_credentials.json
resource "kubernetes_secret" "google_cred" {
  metadata {
    name      = "google-cred"
    namespace = local.kafka_namespace
  }

  data = {
    application_default_credentialsjson = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))
  }

  type = "kubernetes.io/application_default_credentialsjson"
}


data "kubernetes_secret" "google_cred" {
  metadata {
    name      = "google-cred"
    namespace = local.kafka_namespace
  }
}

resource "kubernetes_manifest" "kafka_sink_bigquery" {
  manifest = yamldecode(replace(file("${path.module}/kafka-sink-bigquery.yaml"), "{{ GOOGLE_CREDENTIALS }}", jsonencode(data.kubernetes_secret.google_cred.data["application_default_credentialsjson"])))
}

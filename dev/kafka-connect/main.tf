variable "name_prefix" {}

locals {
  kafka_namespace = "${var.name_prefix}-kafka"
  #  galoy_namespace        = "${var.name_prefix}-galoy"
  #  mongodb_password       = "password" # data.kubernetes_secret.mongodb_creds.data["mongodb-password"]
  #  mongodb_connection_uri = "mongodb://testGaloy:${local.mongodb_password}@galoy-mongodb-headless.${local.galoy_namespace}.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0"
}

terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
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


locals {
  google_credentials = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))
}

#data "google_service_account" "kafka_sa" {
#  account_id = local.kafka_sa
#}
#
#resource "google_service_account_key" "kafka_sa_key" {
#  service_account_id = data.google_service_account.kafka_sa.id
#}

resource "kubernetes_secret" "kafka_sa_key_secret" {
  metadata {
    name      = "kafka-sa-key-secret"
    namespace = local.kafka_namespace
  }

  data = {
    keyfile = local.google_credentials
  }
}


## CONNECT
resource "kubernetes_manifest" "kafka_connect" {
  manifest = yamldecode(file("${path.module}/kafka-connect.yaml"))
}

## TOPICS BY THE TERRAFORM PROVIDER

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


## SOURCE CONNECTORS
#resource "kubernetes_manifest" "kafka_source_mongo_medici-balances" {
#  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-balances.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
#}
#
#resource "kubernetes_manifest" "kafka_source_mongo_medici-journals" {
#  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-journals.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
#}
#
#resource "kubernetes_manifest" "kafka_source_mongo_medici-transaction-metadatas" {
#  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-transaction-metadatas.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
#}
#
#resource "kubernetes_manifest" "kafka_source_mongo_medici-transactions" {
#  manifest = yamldecode(replace(file("${path.module}/kafka-source-mongo-medici-transactions.yaml"), "{{ MONGODB_CONNECTION_URI }}", local.mongodb_connection_uri))
#}
#

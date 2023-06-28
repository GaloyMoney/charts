variable "name_prefix" {}

locals {
  kafka_namespace = "${var.name_prefix}-kafka"
  #  galoy_namespace        = "${var.name_prefix}-galoy"
  #  mongodb_password       = "password" # data.kubernetes_secret.mongodb_creds.data["mongodb-password"]
  #  mongodb_connection_uri = "mongodb://testGaloy:${local.mongodb_password}@galoy-mongodb-headless.${local.galoy_namespace}.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0"
  smoketest_namespace = "${var.name_prefix}-smoketest"
  google_credentials = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))

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

resource "kubernetes_secret" "kafka_connect_smoketest" {
  metadata {
    name      = "kafka-connect-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    kafka_connect_api_host = "kafka-connect-api.${local.kafka_namespace}.svc.cluster.local"
    kafka_connect_api_port = 8083
  }
}

resource "kubernetes_secret" "kafka_sa_key_secret" {
  metadata {
    name      = "kafka-sa-creds"
    namespace = local.kafka_namespace
  }

  data = {
    keyfile = local.google_credentials
  }
}

## CONNECT
resource "helm_release" "kafka_connect" {
  name      = "kafka-connect"
  chart     = "${path.module}/../../charts/kafka-connect"
  namespace = local.kafka_namespace

  values = [
    templatefile("${path.module}/kafka-values.yml.tmpl", {
      allowed_namespace = local.smoketest_namespace
    })
  ]

  dependency_update = true
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

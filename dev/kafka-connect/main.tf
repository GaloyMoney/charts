variable "name_prefix" {}

locals {
  kafka_namespace = "${var.name_prefix}-kafka"
  #  galoy_namespace        = "${var.name_prefix}-galoy"
  #  mongodb_password       = "password" # data.kubernetes_secret.mongodb_creds.data["mongodb-password"]
  #  mongodb_connection_uri = "mongodb://testGaloy:${local.mongodb_password}@galoy-mongodb-headless.${local.galoy_namespace}.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0"
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
    name      = "kafka-sa-creds"
    namespace = local.kafka_namespace
  }

  data = {
    keyfile = local.google_credentials
  }
}


## CONNECT
#resource "kubernetes_manifest" "kafka_connect_build" {
#  manifest = yamldecode(file("${path.module}/kafka-connect-build.yaml"))
#}

resource "kubernetes_manifest" "kafka_connect" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnect"
    metadata = {
      name      = "kafka"
      namespace = local.kafka_namespace
      annotations = {
        "strimzi.io/use-connector-resources" = "true"
      }
    }
    spec = {
      version          = "3.4.0"
      #image            = "docker.io/openoms/strimzi-connect-mongo-postgres-bigquery@sha256:5d9992106cb9c71057be3a79391f9cc0f60197a0e8a8386d0ca262a673fe09d6"
      image            = "docker.io/openoms/strimzi-connect-mongo-postgres-bigquery@sha256:3e7b46022e4ee2ba3d3e8650d08b3c6e93b75085d946c61a162023c57da4b593"
      replicas         = 1
      bootstrapServers = "kafka-kafka-plain-bootstrap:9092"
      config = {
        "group.id"             = "connect-cluster"
        "offset.storage.topic" = "connect-cluster-offsets"
        "config.storage.topic" = "connect-cluster-configs"
        "status.storage.topic" = "connect-cluster-status"
        # -1 means it will use the default replication factor configured in the broker
        "config.storage.replication.factor" = -1
        "offset.storage.replication.factor" = -1
        "status.storage.replication.factor" = -1
      }
      externalConfiguration = {
        volumes = [
          {
            name = "kafka-sa-creds"
            secret = {
              secretName = "kafka-sa-creds"
            }
          }
        ]
      }
    }
  }
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

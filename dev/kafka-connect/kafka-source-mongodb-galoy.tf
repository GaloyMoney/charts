locals {
  galoy_namespace        = "${var.name_prefix}-galoy"
  mongodb_password       = data.kubernetes_secret.mongodb_creds.data["mongodb-password"]
  mongodb_connection_uri = sensitive("mongodb://testGaloy:${local.mongodb_password}@galoy-mongodb-headless.${local.galoy_namespace}.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0")
  collections = [
    "medici_balances",
    "medici_journals",
    "medici_transaction_metadatas",
    "medici_transactions"
  ]
}

data "kubernetes_secret" "mongodb_creds" {
  metadata {
    name      = "galoy-mongodb"
    namespace = local.galoy_namespace
  }
}

resource "kafka_topic" "kafka_source_mongo" {
  for_each = toset(local.collections)

  name               = "mongodb_galoy_${each.value}"
  partitions         = 1
  replication_factor = 3
}

resource "kubernetes_manifest" "kafka_source_mongo" {
  for_each = toset(local.collections)

  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "kafka-source-mongo-medici-balances"
      namespace = local.kafka_namespace
      labels = {
        "strimzi.io/cluster" = "kafka"
      }
    }
    spec = {
      class    = "com.mongodb.kafka.connect.MongoSourceConnector"
      tasksMax = 1
      config = {
        "startup.mode"                   = "latest",
        "connection.uri"                 = "password:file:/opt/kafka/external-configuration/mongodb-uri/uri"
        "config.providers"               = "file"
        "config.providers.file.class"    = "org.apache.kafka.common.config.provider.FileConfigProvider"
        "topic.prefix"                   = "mongodb",
        "database"                       = "galoy",
        "topic.separator"                = "_",
        "collection"                     = "${each.value}",
        "output.format.key"              = "schema",
        "output.format.value"            = "schema",
        "output.schema.infer.value"      = true,
        "key.converter.schemas.enable"   = true,
        "value.converter.schemas.enable" = true,
        "key.converter"                  = "org.apache.kafka.connect.json.JsonConverter",
        "value.converter"                = "org.apache.kafka.connect.json.JsonConverter"
      }
    }

  }
}


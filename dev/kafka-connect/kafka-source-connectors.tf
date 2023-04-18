locals {
  galoy_namespace        = "${var.name_prefix}-galoy"
  mongodb_password       = "password" #data.kubernetes_secret.mongodb_creds.data["mongodb-password"]
  mongodb_connection_uri = "mongodb://testGaloy:${local.mongodb_password}@galoy-mongodb.${local.galoy_namespace}.svc.cluster.local:27017/?authSource=galoy&replicaSet=rs0"
}

data "kubernetes_secret" "mongodb_creds" {
  metadata {
    name      = "galoy-mongodb"
    namespace = local.galoy_namespace
  }
}

resource "kubernetes_manifest" "kafka_source_mongo_medici_balances" {
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
        "connection.uri"                 = "${local.mongodb_connection_uri}",
        "topic.prefix"                   = "mongodb",
        "database"                       = "galoy",
        "topic.separator"                = "_",
        "collection"                     = "medici_balances",
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

resource "kubernetes_manifest" "kafka_source_mongo_medici_journals" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "kafka-source-mongo-medici-journals"
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
        "connection.uri"                 = "${local.mongodb_connection_uri}",
        "topic.prefix"                   = "mongodb",
        "database"                       = "galoy",
        "topic.separator"                = "_",
        "collection"                     = "medici_journals",
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

resource "kubernetes_manifest" "kafka_source_mongo_medici_transaction-metadatas" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "kafka-source-mongo-medici-transaction-metadatas"
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
        "connection.uri"                 = "${local.mongodb_connection_uri}",
        "topic.prefix"                   = "mongodb",
        "database"                       = "galoy",
        "topic.separator"                = "_",
        "collection"                     = "medici_transaction_metadatas",
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

resource "kubernetes_manifest" "kafka_source_mongo_medici_transactions" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "kafka-source-mongo-medici-transactions"
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
        "connection.uri"                 = "${local.mongodb_connection_uri}",
        "topic.prefix"                   = "mongodb",
        "database"                       = "galoy",
        "topic.separator"                = "_",
        "collection"                     = "medici_transactions",
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

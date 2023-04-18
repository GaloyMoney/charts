## SINK CONNECTOR
## to use the sink connector locally
## run: gcloud auth application-default login to create th file ~/.config/gcloud/application_default_credentials.json
#resource "kubernetes_secret" "google_cred" {
#  metadata {
#    name      = "google-cred"
#    namespace = local.kafka_namespace
#  }
#
#  data = {
#    application_default_credentialsjson = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))
#  }
#
#  type = "kubernetes.io/application_default_credentialsjson"
#}
#
#data "kubernetes_secret" "google_cred" {
#  metadata {
#    name      = "google-cred"
#    namespace = local.kafka_namespace
#  }
#}

/* locals {
  google_credentials = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))
}

resource "kubernetes_manifest" "kafka_sink_bigquery" {
  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "KafkaConnector"
    "metadata" = {
      "name"      = "kafka-sink-bigquery"
      "namespace" = "galoy-dev-kafka"
      "labels" = {
        "strimzi.io/cluster" = "kafka"
      }
      "annotations" = {}
    }
    spec = {
      class    = "com.wepay.kafka.connect.bigquery.BigQuerySinkConnector"
      tasksMax = 1
      config = {
        "name"                                 = "kafka-sink-bigquery"
        "tasks.max"                            = 1
        "topics"                               = "mongodb_galoy_medici_balances,mongodb_galoy_medici_journals,mongodb_galoy_medici_transaction_metadatas,mongodb_galoy_medici_transactions"
        "project"                              = "galoy-reporting"
        "datasets"                             = ".*=dataform_oms"
        "keyfile"                              = local.google_credentials
        "keySource"                            = "JSON"
        "sanitizeTopics"                       = true
        "sanitizeFieldNames"                   = true
        "autoCreateTables"                     = false
        "allowNewBigQueryFields"               = true
        "allowBigQueryRequiredFieldRelaxation" = true
        "allowSchemaUnionization"              = false
        "upsertEnabled"                        = true
        "deleteEnabled"                        = true
        "bigQueryRetry"                        = 5
        "bigQueryRetryWait"                    = 15000
        "config.action.reload"                 = "restart"
        "timestamp"                            = "UTC"
        "key.converter"                        = "org.apache.kafka.connect.json.JsonConverter"
        "key.converter.schemas.enable"         = true
        "value.converter"                      = "org.apache.kafka.connect.json.JsonConverter"
        "value.converter.schemas.enable"       = true

        "errors.tolerance"                                = "all"
        "errors.log.enable"                               = true
        "errors.log.include.messages"                     = true
        "errors.deadletterqueue.context.headers.enable"   = true
        "errors.deadletterqueue.topic.name"               = "dlq_bigquery_sink"
        "errors.deadletterqueue.topic.replication.factor" = 1
      }
    }
  }
} */

/*
# connector source: https://github.com/confluentinc/kafka-connect-bigquery
# config options: https://github.com/wepay/kafka-connect-bigquery/wiki/Connector-Configuration

resource "kubernetes_stateful_set" "kafka_connect" {
  metadata {
    name      = "kafka"
    namespace = "galoy-dev-kafka"
  }

  spec {
    service_name = "kafka-connect"
    selector {
      match_labels = {
        app = "kafka-connect"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-connect"
        }
      }

      spec {
        container {
          name  = "kafka-connect"
          image = "docker.io/openoms/strimzi-connect-mongo-bigquery@sha256:ab9bf0a74c17c9e9ab006f302efb1f87641e4cfb9d80c9b0b799ca0d2b27c67c"

          volume_mount {
            name       = "kafka-sa-key-volume"
            mount_path = "/etc/kafka-sa-key"
            read_only  = true
            sub_path   = "keyfile.json"
          }
        }

        volume {
          name = "kafka-sa-key-volume"

          secret {
            secret_name = kubernetes_secret.kafka_sa_key_secret.metadata[0].name
          }
        }
      }
    }

    # Add the rest of the stateful set spec (e.g., replicas)
    replicas         = 1
    version          = "3.4.0"
    image            = "docker.io/openoms/strimzi-connect-mongo-bigquery@sha256:ab9bf0a74c17c9e9ab006f302efb1f87641e4cfb9d80c9b0b799ca0d2b27c67c"
    bootstrapServers = "kafka-kafka-plain-bootstrap:9092"
    config = {
      group_id                          = "connect-cluster"
      offset_storage_topic              = "connect-cluster-offsets"
      config_storage_topic              = "connect-cluster-configs"
      status_storage_topic              = "connect-cluster-status"
      config_storage_replication_factor = -1
      offset_storage_replication_factor = -1
      status_storage_replication_factor = -1
    }
  }
}
*/




resource "kubernetes_manifest" "kafka_sink_bigquery" {
  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "KafkaConnector"
    "metadata" = {
      "name"      = "kafka-sink-bigquery"
      "namespace" = "galoy-dev-kafka"
      "labels" = {
        "strimzi.io/cluster" = "kafka"
      }
      "annotations" = {}
    }
    spec = {
      class    = "com.wepay.kafka.connect.bigquery.BigQuerySinkConnector"
      tasksMax = 1
      config = {
        "name"      = "kafka-sink-bigquery"
        "tasks.max" = 1
        "topics"    = "mongodb_galoy_medici_balances,mongodb_galoy_medici_journals,mongodb_galoy_medici_transaction_metadatas,mongodb_galoy_medici_transactions"
        "project"   = "galoy-reporting"
        "datasets"  = ".*=dataform_galoy-staging"
        #"keyfile"                              = "/etc/kafka-sa-key/keyfile.json"
        #"keyfile"                              = base64decode(kubernetes_secret.kafka_sa_key_secret.data["keyfile"], sensitive = true)
        "keyfile"                              = "/opt/kafka/external-configuration/kafka-sa-key-secret/keyfile",
        "keySource"                            = "FILE"
        "sanitizeTopics"                       = true
        "sanitizeFieldNames"                   = true
        "autoCreateTables"                     = false
        "allowNewBigQueryFields"               = true
        "allowBigQueryRequiredFieldRelaxation" = true
        "allowSchemaUnionization"              = false
        "upsertEnabled"                        = true
        "deleteEnabled"                        = true
        "bigQueryRetry"                        = 5
        "bigQueryRetryWait"                    = 15000
        "config.action.reload"                 = "restart"
        "timestamp"                            = "UTC"
        "key.converter"                        = "org.apache.kafka.connect.json.JsonConverter"
        "key.converter.schemas.enable"         = true
        "value.converter"                      = "org.apache.kafka.connect.json.JsonConverter"
        "value.converter.schemas.enable"       = true

        "errors.tolerance"                                = "all"
        "errors.log.enable"                               = true
        "errors.log.include.messages"                     = true
        "errors.deadletterqueue.context.headers.enable"   = true
        "errors.deadletterqueue.topic.name"               = "dlq_bigquery_sink"
        "errors.deadletterqueue.topic.replication.factor" = 1
      }
    }
  }
}

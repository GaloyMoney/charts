/*# Create google credentials
gcloud auth application-default login
cat ~/.config/gcloud/application_default_credentials.json
*/

locals{
  topics = [
    #"mongodb_galoy_medici_balances",
    #"mongodb_galoy_medici_journals",
    #"mongodb_galoy_medici_transaction_metadatas",
    #"mongodb_galoy_medici_transactions",
    "pg_stablesats_public_galoy_transactions",
    "pg_stablesats_public_okex_orders",
    "pg_stablesats_public_okex_transfers",
    "pg_stablesats_public_sqlx_ledger_balances",
    "pg_stablesats_public_user_trades"
  ]
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
        "name"      = "kafka-sink-bigquery"
        "tasks.max" = 1
        "topics"    = join(",", local.topics)
        "project"   = "galoy-reporting"
        "datasets"  = ".*=dataform_oms="
        #"datasets" = ".*=${local.dataset_id}"
        "keyfile"                              = "/opt/kafka/external-configuration/kafka-sa-creds/keyfile",
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

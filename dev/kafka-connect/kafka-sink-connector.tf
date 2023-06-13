
/*# Create google credentials
gcloud auth application-default login
cat ~/.config/gcloud/application_default_credentials.json
kubectl -n galoy-dev-kafka create secret generic google-cred \
    --from-file=application_default_credentialsjson=$HOME/.config/gcloud/application_default_credentials.json \
    --type=kubernetes.io/application_default_credentialsjson
kubectl -n galoy-dev-kafka get secret google-cred --output=yaml
*/

locals{
  topics = [
    "mongodb_galoy_medici_balances",
    "mongodb_galoy_medici_journals",
    "mongodb_galoy_medici_transaction_metadatas",
    "mongodb_galoy_medici_transactions",
    "stablesats.public.galoy_transactions",
    "stablesats.public.okex_orders",
    "stablesats.public.okex_transfers",
    "stablesats.public.sqlx_ledger_accounts",
    "stablesats.public.sqlx_ledger_balances",
    "stablesats.public.sqlx_ledger_current_balances",
    "stablesats.public.sqlx_ledger_entries",
    "stablesats.public.sqlx_ledger_events",
    "stablesats.public.sqlx_ledger_journals",
    "stablesats.public.sqlx_ledger_transactions",
    "stablesats.public.sqlx_ledger_tx_templates",
    "stablesats.public.user_trades"
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
        #"datasets"  = ".*=dataform_galoy-staging"
        "keyfile"                              = base64decode(kubernetes_secret.kafka_sa_key_secret.data["keyfile"], sensitive = true)
        #"keyfile"                              = "/opt/kafka/external-configuration/kafka-sa-key-secret/keyfile",
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

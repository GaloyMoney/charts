varibale replicator_password {}
variable host {}

locals {
  stablesats_namespace = "${var.name_prefix}-stablesats"
  tables = [
    "public._sqlx_migrations",
    "public.galoy_transactions",
    "public.mq_msgs",
    "public.mq_payloads",
    "public.okex_orders",
    "public.okex_transfers",
    "public.sqlx_ledger_accounts",
    "public.sqlx_ledger_balances",
    "public.sqlx_ledger_current_balances",
    "public.sqlx_ledger_entries",
    "public.sqlx_ledger_events",
    "public.sqlx_ledger_journals",
    "public.sqlx_ledger_transactions",
    "public.sqlx_ledger_tx_templates",
    "public.user_trades"
  ]

}

data "kubernetes_secret" "stablesats" {
  metadata {
    name      = "stablesats"
    namespace = local.stablesats_namespace
  }
}

resource "kubernetes_secret" "stablesats_creds" {
  metadata {
    name      = "stablesats-creds"
    namespace = local.kafka_namespace
  }
  data = {
    pg-host : "stablesats-postgresql.${local.stablesats_namespace}.svc.cluster.local"
  }
}

resource "kubernetes_secret" "stablesats" {
  metadata {
    name      = "stablesats"
    # will need to move namespaces
    namespace = local.kafka_namespace
  }

  data = {
    pg-host : local.host
    pg-replicator-password : local.replicator_password
  }
}

## kafka_source_postgres
resource "kubernetes_manifest" "kafka-source-postgres" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "kafka-source-postgres"
      namespace = local.kafka_namespace
      labels = {
        "strimzi.io/cluster" = "kafka"
      }
    }
    spec = {
      class    = "io.debezium.connector.postgresql.PostgresConnector"
      tasksMax = 1
      config = {
        "database.hostname" : kubernetes_secret.stablesats.data["pg-host"],
        "database.port" : 5432
        "database.user" : "stablesats-replicator",
        "database.password" : kubernetes_secret.stablesats.data["pg-replicator-password"],
        "database.dbname" : "stablesats",
        "topic.prefix" : "stablesats",
        "table.include.list" : join(",", local.tables),
        #        "table.include.list": "public.inventory" 
        #        "database_server_name"                     = "postgres"
        #        "database_dbname"                          = "stablesats"
        #        "schema_include_list"                      = "inventory"
        #        "config_action_reload"                     = "restart"
        #        "publication_autocreate_mode"              = "all_tables"
        #        "database_history_kafka_bootstrap_servers" = "kafka-kafka-plain-bootstrap:9092"
        #        "key_converter"                            = "org.apache.kafka.connect.json.JsonConverter"
        #        "key_converter_schemas_enable"             = true
        #        "value_converter"                          = "org.apache.kafka.connect.json.JsonConverter"
        #        "value_converter_schemas_enable"           = true
        #        "header_converter"                         = "org.apache.kafka.connect.json.JsonConverter"
        #        "transforms"                               = "unwrap"
        #        "transforms_unwrap_add_fields"             = "op,table,source.ts_ms"
        #        "transforms_unwrap_delete_handling_mode"   = "rewrite"
        #        "transforms_unwrap_drop_tombstones"        = false
        #        "transforms_unwrap_type"                   = "io.debezium.transforms.ExtractNewRecordState"
        #        "message_key_columns"                      = "inventory.no_pk:created_at"
      }
    }
  }
}

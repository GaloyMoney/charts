variable "replicator_password" {}
variable "host" {}

locals {
  replicator_password  = var.replicator_password
  host                 = var.host
  stablesats_namespace = "${var.name_prefix}-stablesats"
  tables = [
    "public.galoy_transactions",
    "public.okex_orders",
    "public.okex_transfers",
    "public.sqlx_ledger_balances",
    "public.user_trades"
  ]
}

resource "kubernetes_secret" "stablesats" {
  metadata {
    name = "stablesats"
    namespace = local.kafka_namespace
  }

  data = {
    pg-host : local.host
    pg-replicator-password : local.replicator_password
  }
}

# create topics for kafka_source_postgres
resource "kafka_topic" "kafka_source_postgres" {
  for_each = toset(local.tables)
  # use underscores in the topic names for consistency
  # naming convention: "<database>_<runtime>_<table>"
  name               = replace("pg_stablesats_${each.value}", ".", "_")
  partitions         = 1
  replication_factor = 3
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
        # options: https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-connector-properties
        "database.hostname" : kubernetes_secret.stablesats.data["pg-host"]
        "database.port" : 5432
        "database.user" : "stablesats-replicator"
        "database.password" : kubernetes_secret.stablesats.data["pg-replicator-password"]
        "database.dbname" : "stablesats"
        "topic.prefix" : "pg_stablesats"
        "topic.delimiter" : "_"
        "table.include.list" : join(",", local.tables)
        #"snapshot.mode" : "always"
        #"table.include.list": "public.inventory" 
        #"database_server_name"                     = "postgres"
        #"database_dbname"                          = "stablesats"
        #"schema_include_list"                      = "inventory"
        #"config_action_reload"                     = "restart"
        #"publication_autocreate_mode"              = "all_tables"
        #"database_history_kafka_bootstrap_servers" = "kafka-kafka-plain-bootstrap:9092"
        #"key_converter"                            = "org.apache.kafka.connect.json.JsonConverter"
        #"key_converter_schemas_enable"             = true
        #"value_converter"                          = "org.apache.kafka.connect.json.JsonConverter"
        #"value_converter_schemas_enable"           = true
        #"header_converter"                         = "org.apache.kafka.connect.json.JsonConverter"
        #"transforms"                               = "unwrap"
        #"transforms_unwrap_add_fields"             = "op,table,source.ts_ms"
        #"transforms_unwrap_delete_handling_mode"   = "rewrite"
        #"transforms_unwrap_drop_tombstones"        = false
        #"transforms_unwrap_type"                   = "io.debezium.transforms.ExtractNewRecordState"
        #"message_key_columns"                      = "inventory.no_pk:created_at"
      }
    }
  }
}

terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
}

locals {
  stablesats_namespace = "${var.name_prefix}-stablesats"
  stablesats_db_con    = "postgresql://stablesats:${data.kubernetes_secret.stablesats.data["pg-user-pw"]}@$stablesats-postgresql.${local.stablesats_namespace}.svc.cluster.local:5432/stablesats"
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


#resource "kubernetes_secret" "stablesats_creds" {
#  metadata {
#    name      = "stablesats-creds"
#    namespace = local.kafka_namespace
#  }
#
#  data = {
#    password : data.kubernetes_secret.stablesats.data["pg-user-pw"]
#
#  }
#}


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
      class     = "io.debezium.connector.postgresql.PostgresConnector"
      tasksMax = 1
      config = {
        "database.hostname": kubernetes_secret.stablesats_creds.data["pg-host"],
        "database.port": 5432
        "database.user": "stablesats", 
        "database.password": data.kubernetes_secret.stablesats.data["pg-user-pw"], 
        "database.dbname" : "stablesats", 
        "topic.prefix": "stablesats", 
        "table.include.list": "public.inventory" 

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

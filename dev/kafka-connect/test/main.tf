variable "replicator_password" { default = "" }
variable "host" { default = "" }

locals {
  replicator_password  = var.replicator_password
  host                 = var.host
  #stablesats_namespace = "${var.name_prefix}-stablesats"
  tables = [
    "public.galoy_transactions",
    "public.okex_orders",
    "public.okex_transfers",
    "public.sqlx_ledger_balances",
    "public.user_trades"
  ]
}

resource "kafka_topic" "kafka_source_postgres" {
  for_each = toset(local.tables)
  # use underscores in the topic names for consistency
  #name               = replace("pg_stablesats_${each.value}", "\\.", "_")
  name               = "pg_stablesats_${each.value}"
  partitions         = 1
  replication_factor = 3
}


data "external" "kafka_bootstrap_ip" {
  program = ["${path.module}/../bin/get_kafka_bootstrap_ip.sh"]
}

data "external" "kafka_bootstrap_nodeport" {
  program = ["${path.module}/../bin/get_kafka_bootstrap_nodeport.sh"]
}

provider "kafka" {
  bootstrap_servers = ["${lookup(data.external.kafka_bootstrap_ip.result, "result")}:${lookup(data.external.kafka_bootstrap_nodeport.result, "result")}"]
  tls_enabled       = false
}


terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.5.2"
    }
  }
}

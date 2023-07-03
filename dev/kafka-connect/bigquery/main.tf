# gcloud auth login
# gcloud config set project PROJECT_ID

locals {
  tables = [
    "pg_stablesats_public_galoy_transactions",
    "pg_stablesats_public_okex_orders",
    "pg_stablesats_public_okex_transfers",
    "pg_stablesats_public_sqlx_ledger_balances",
    "pg_stablesats_public_user_trades"
  ]
}

# create tables in the dataset to match the tables streamed from the stablesats postgres
resource "google_bigquery_table" "postgres_stablesats" {
  for_each = toset(local.tables)

  project    = "galoy-reporting"
  dataset_id = "dataform_oms"
  table_id   = each.value
  time_partitioning {
    type = "DAY"
  }
  deletion_protection = false
  schema              = file("${path.module}/bigquery-schemas/${each.value}.json")
}

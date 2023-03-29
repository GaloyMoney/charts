provider "google" {
  project     = "galoy-reporting"
  credentials = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))
}

resource "google_bigquery_table" "mongodb_galoy_medici_balances" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_balances"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/bigquery-schema-mongo-medici-balances.json")

  lifecycle {
    create_before_destroy = false
  }
}

resource "google_bigquery_table" "mongodb_galoy_medici_journals" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_journals"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/bigquery-schema-mongo-medici-journals.json")

  lifecycle {
    create_before_destroy = false
  }
}

resource "google_bigquery_table" "mongodb_galoy_medici_transaction_metadatas" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_transaction_metadatas"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/bigquery-schema-mongo-medici-transaction-metadatas.json")

  lifecycle {
    create_before_destroy = false
  }
}

resource "google_bigquery_table" "mongodb_galoy_medici_transactions" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_transactions"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/bigquery-schema-mongo-medici-transactions.json")

  lifecycle {
    create_before_destroy = false
  }
}

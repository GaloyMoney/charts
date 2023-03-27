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
  schema = file("${path.module}/schema-mongo-medici.json")
}

resource "google_bigquery_table" "mongodb_galoy_medici_journals" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_journals"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/schema-mongo-medici.json")
}

resource "google_bigquery_table" "mongodb_galoy_medici_locks" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_locks"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/schema-mongo-medici.json")
}

resource "google_bigquery_table" "mongodb_galoy_medici_transaction_metadatas" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_transaction_metadatas"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/schema-mongo-medici.json")
}

resource "google_bigquery_table" "mongodb_galoy_medici_transactions" {
  dataset_id = "dataform_oms"
  table_id   = "mongodb_galoy_medici_transactions"
  time_partitioning {
    type = "DAY"
  }
  schema = file("${path.module}/schema-mongo-medici.json")
}

variable "gcp_project" { default = "testproject-387808" }
variable "db_name" { default = "stablesats" }
variable "admin_user_name" { default = "stablesats-user" }
variable "user_name" { default = "stablesats-user" }
variable "replication" { default = true }

#resource "postgresql_role" "user" {
#  name     = var.user_name
#  password = "UnvaluedGatingPurgingFlavoredPledgeAfflicted"
#  login    = true
#}

output "replicator_password" {
  value = var.replication ? random_password.replicator[0].result : null
  sensitive = true
}

resource "random_password" "replicator" {
  count   = var.replication ? 1 : 0
  length  = 20
  special = false
}

resource "postgresql_role" "replicator" {
  count       = var.replication ? 1 : 0
  name        = "${var.db_name}-replicator"
  password    = random_password.replicator[0].result
  login       = true
  replication = true
}


resource "postgresql_grant" "revoke_public" {
  database    = var.db_name
  role        = "public"
  object_type = "database"
  privileges  = []
}

#resource "postgresql_database" "db" {
#  name       = var.db_name
#  owner      = var.admin_user_name
#  template   = "template0"
#  lc_collate = "en_US.UTF8"
#}

resource "postgresql_grant" "grant_all" {
  database    = var.db_name
  role        = var.user_name
  object_type = "database"

  # Basically "ALL" but then tf will redeploy
  privileges = ["CONNECT", "CREATE", "TEMPORARY"]

  depends_on = [
    postgresql_grant.revoke_public,
  ]
}

resource "postgresql_grant" "grant_connect_replicator" {
  count       = var.replication ? 1 : 0
  database    = var.db_name
  role        = postgresql_role.replicator[0].name
  object_type = "database"

  privileges = ["CONNECT"]

  depends_on = [
    postgresql_grant.revoke_public,
  ]
}

resource "postgresql_grant" "replication_grant" {
  count       = var.replication ? 1 : 0
  database    = var.db_name
  role        = postgresql_role.replicator[0].name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT"]
  depends_on = [
    postgresql_grant.revoke_public,
  ]
}

provider "postgresql" {
  host     = "127.0.0.1"
  port     = 5433
  username = "stablesats-user"
  password = "UnvaluedGatingPurgingFlavoredPledgeAfflicted"
  sslmode = "disable"

  # GCP doesn't let superuser mode https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}


terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.19.0"
    }
  }
}

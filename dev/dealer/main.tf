variable "name_prefix" {}

locals {
  dealer_namespace  = "${var.name_prefix}-dealer"
  postgres_password = "postgres"
  postgres_db_uri   = "postgres://postgres:postgres@dealer-postgresql:5432/dealer"
}

resource "kubernetes_namespace" "dealer" {
  metadata {
    name = local.dealer_namespace
  }
}

resource "kubernetes_secret" "postgres_creds" {
  metadata {
    name      = "dealer-postgres"
    namespace = kubernetes_namespace.dealer.metadata[0].name
  }

  data = {
    "postgresql-password" : local.postgres_password
    "postgresql-db-uri" : local.postgres_db_uri
  }
}

resource "helm_release" "dealer" {
  name       = "dealer"
  chart      = "${path.module}/../../charts/dealer"
  repository = "https://galoymoney.github.io/charts"
  namespace  = kubernetes_namespace.dealer.metadata[0].name

  values = [
    file("${path.module}/dealer-values.yml")
  ]

  depends_on = [
    kubernetes_secret.postgres_creds
  ]

  dependency_update = true
}

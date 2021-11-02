variable "name_prefix" {}

locals {
  dealer_namespace = "${var.name_prefix}-dealer"
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
    "postgresql-username" : "postgres"
    "postgresql-password" : "postgres"
    "postgresql-database" : "dealer"
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

  dependency_update = true
}

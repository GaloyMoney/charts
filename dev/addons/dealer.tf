locals {
  postgres_password   = "postgres"
  postgres_db_uri     = "postgres://postgres:postgres@dealer-postgresql:5432/dealer"
  okex5_key           = "key"
  okex5_secret        = "secret"
  okex5_password      = "pwd"
  okex5_fund_password = "none"
}

resource "kubernetes_secret" "okex5_creds" {
  metadata {
    name      = "dealer-okex5"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = {
    "okex5_key" : local.okex5_key
    "okex5_secret" : local.okex5_secret
    "okex5_password" : local.okex5_password
    "okex5_fund_password" : local.okex5_fund_password
  }
}

resource "kubernetes_secret" "postgres_creds" {
  metadata {
    name      = "dealer-postgres"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = {
    "postgresql-password" : local.postgres_password
    "postgresql-db-uri" : local.postgres_db_uri
  }
}

resource "helm_release" "dealer" {
  name      = "dealer"
  chart     = "${path.module}/../../charts/dealer"
  namespace = kubernetes_namespace.addons.metadata[0].name

  values = [
    templatefile("${path.module}/dealer-values.yml.tmpl", {
      addons_namespace : kubernetes_namespace.addons.metadata[0].name
    })
  ]

  depends_on = [
    kubernetes_secret.postgres_creds,
    kubernetes_secret.okex5_creds
  ]

  dependency_update = true
}

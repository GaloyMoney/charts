variable "name_prefix" {}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
  auth_namespace      = "${var.name_prefix}-auth"

  session_keys = "session-keys"

  postgres_database = "auth_db"
  postgres_password = "postgres"
}

resource "kubernetes_namespace" "auth" {
  metadata {
    name = local.auth_namespace
  }
}

resource "kubernetes_secret" "galoy_auth_smoketest" {
  metadata {
    name      = "galoy-auth-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    kratos_admin_endpoint = "galoy-auth-kratos-admin.${local.auth_namespace}.svc.cluster.local"
    kratos_admin_port     = 80
  }
}

resource "kubernetes_secret" "auth_backend" {
  metadata {
    name      = "auth-backend"
    namespace = local.auth_namespace
  }
  data = {
    "session-keys" : local.session_keys
  }
}

resource "helm_release" "galoy_auth" {
  name      = "galoy-auth"
  chart     = "${path.module}/../../charts/galoy-auth"
  namespace = kubernetes_namespace.auth.metadata[0].name

  values = [
    templatefile("${path.module}/galoy-auth-dev-values.yml.tmpl", {
      postgres_database : local.postgres_database
      postgres_password : local.postgres_password
    })
  ]

  dependency_update = true

  depends_on = [helm_release.postgres]
}

resource "helm_release" "postgres" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.auth.metadata[0].name

  values = [
    templatefile("${path.module}/postgres-testflight-values.yml.tmpl", {
      postgres_database : local.postgres_database
      postgres_password : local.postgres_password
    })
  ]
}

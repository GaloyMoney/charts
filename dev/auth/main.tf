variable "name_prefix" {}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
  auth_namespace      = "${var.name_prefix}-auth"
}

resource "kubernetes_namespace" "auth" {
  metadata {
    name = local.auth_namespace
  }
}

resource "helm_release" "galoy_auth" {
  name      = "galoy-auth"
  chart     = "${path.module}/../../charts/galoy-auth"
  namespace = kubernetes_namespace.auth.metadata[0].name

  values = [
    file("${path.module}/auth-values.yml")
  ]

  dependency_update = true
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

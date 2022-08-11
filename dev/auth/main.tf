variable "name_prefix" {}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
  auth_namespace      = "${var.name_prefix}-auth"

  session_keys = "session_keys"
}

resource "kubernetes_namespace" "auth" {
  metadata {
    name = local.auth_namespace
  }
}

resource "kubernetes_secret" "auth_backend_secret" {
  metadata {
    name      = "auth-backend"
    namespace = kubernetes_namespace.auth.metadata[0].name
  }

  data = {
    "session-keys" : local.session_keys
  }
}

resource "helm_release" "galoy_auth" {
  name      = "galoy-auth"
  chart     = "${path.module}/../../charts/galoy-auth"
  namespace = kubernetes_namespace.auth.metadata[0].name

  depends_on = [kubernetes_secret.auth_backend_secret]

  dependency_update = true
}

resource "kubernetes_secret" "galoy_auth_smoketest" {
  metadata {
    name      = "galoy-auth-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_auth_endpoint = "auth-backend.${local.auth_namespace}.svc.cluster.local"
    galoy_auth_port     = 80
  }
}

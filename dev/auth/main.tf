variable "name_prefix" {}

locals {
  auth_namespace = "${var.name_prefix}-auth"

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
}

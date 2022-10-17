variable watch_namespaces {
  default     = []
}

resource "kubernetes_namespace" "galoy-deps" {
  metadata {
    name = "galoy-deps"
  }
}

locals {
  watch_namespaces = var.watch_namespaces
}

resource "helm_release" "galoy_deps" {
  name       = "galoy-deps"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace  = "galoy-deps"
  version    = "0.31.1"

  values = [
    templatefile("${path.module}/galoy-deps-values.yml.tmpl", {
      watch_namespaces: local.watch_namespaces
    })
  ]

  dependency_update = true
}

locals {
  otel_namespace = "${var.name_prefix}-deps-otel"
}

resource "kubernetes_namespace" "otel" {
  metadata {
    name = local.otel_namespace
  }
}

resource "helm_release" "otel" {
  name      = "otel"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace = kubernetes_namespace.otel.metadata[0].name

  values = [
    file("${path.module}/otel-values.yml")
  ]

  dependency_update = true
}

variable "watch_namespaces" {
  default = []
}


resource "kubernetes_namespace" "kafka" {
  metadata {
    name = local.kafka_namespace
  }
}

locals {
  watch_namespaces = var.watch_namespaces
  kafka_namespace  = "${var.name_prefix}-kafka"
}

resource "helm_release" "kafka" {
  name      = "kafka"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace = kubernetes_namespace.kafka.metadata[0].name

  values = [
    templatefile("${path.module}/kafka-values.yml.tmpl", {
      watch_namespaces : local.watch_namespaces
    })
  ]

  dependency_update = true

  depends_on = [
    helm_release.otel
  ]
}

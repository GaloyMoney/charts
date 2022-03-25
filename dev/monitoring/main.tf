variable "name_prefix" {}

locals {
  monitoring_namespace = "${var.name_prefix}-monitoring"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.monitoring_namespace
  }
}

resource "helm_release" "monitoring" {
  name      = "monitoring"
  chart     = "${path.module}/../../charts/monitoring"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/monitoring-values.yml")
  ]

  dependency_update = true
}

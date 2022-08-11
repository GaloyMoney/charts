variable "name_prefix" {}

locals {
  smoketest_namespace  = "${var.name_prefix}-smoketest"
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

resource "kubernetes_secret" "monitoring_smoketest" {
  metadata {
    name      = "monitoring-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    grafana_host = "monitoring-grafana.${local.monitoring_namespace}.svc.cluster.local"
  }
}

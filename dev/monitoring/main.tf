variable "name_prefix" {}

locals {
  smoketest_namespace  = "${var.name_prefix}-smoketest"
  monitoring_namespace = "${var.name_prefix}-monitoring"
  bitcoin_namespace    = "${var.name_prefix}-bitcoin"
  galoy_namespace      = "${var.name_prefix}-galoy"
  grafana_url          = "monitoring-grafana.${var.name_prefix}-monitoring.svc.cluster.local"
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
    templatefile("${path.module}/monitoring-values.yml.tmpl", {
      namespace : local.monitoring_namespace
    })
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

resource "grafana_dashboard" "main" {
  overwrite = true
  config_json = templatefile("${path.module}/dashboard.json", {
    title : "${var.name_prefix} dashboard"
    bitcoin_namespace : local.bitcoin_namespace
    galoy_namespace : local.galoy_namespace
  })

  depends_on = [
    helm_release.monitoring,
  ]
}

provider "grafana" {
  url  = "http://${local.grafana_url}"
  auth = "admin:${data.kubernetes_secret.monitoring-grafana.data["admin-password"]}"
}

data "kubernetes_secret" "monitoring-grafana" {
  metadata {
    namespace = local.monitoring_namespace
    name      = "monitoring-grafana"
  }

  depends_on = [
    helm_release.monitoring,
  ]
}

output "grafana_password" {
  sensitive = true
  value     = data.kubernetes_secret.monitoring-grafana.data["admin-password"]

  depends_on = [
    helm_release.monitoring,
  ]
}

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.13.4"
    }
  }
}

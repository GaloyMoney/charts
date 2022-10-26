variable "watch_namespaces" {
  default = []
}

resource "kubernetes_namespace" "galoy_deps" {
  metadata {
    name = "galoy-deps"
  }
}

locals {
  watch_namespaces = var.watch_namespaces
}

resource "helm_release" "galoy_deps" {
  name      = "galoy-deps"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace = kubernetes_namespace.galoy_deps.metadata[0].name
  version   = "0.31.1"

  values = [
    templatefile("${path.module}/galoy-deps-values.yml.tmpl", {
      watch_namespaces : local.watch_namespaces
    })
  ]

  dependency_update = true
}

resource "kubectl_manifest" "kafka_topic" {
  yaml_body = <<YAML
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: topic
  namespace: ${kubernetes_namespace.galoy_deps.metadata[0].name}
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 7200000
    segment.bytes: 1073741824
YAML

  depends_on = [helm_release.galoy_deps]
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

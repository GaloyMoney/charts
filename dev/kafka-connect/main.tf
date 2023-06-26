variable "name_prefix" {
  default = "galoy-dev"
}

locals {
  kafka_namespace     = "${var.name_prefix}-kafka"
  smoketest_namespace = "${var.name_prefix}-smoketest"
}

resource "kubernetes_secret" "kafka_connect_smoketest" {
  metadata {
    name      = "kafka-connect-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    kafka_connect_api_host = "kafka-connect-api.${local.kafka_namespace}.svc.cluster.local"
    kafka_connect_api_port = 8083
  }
}

resource "helm_release" "kafka_connect" {
  name      = "kafka-connect"
  chart     = "${path.module}/../../charts/kafka-connect"
  namespace = local.kafka_namespace

  dependency_update = true
}

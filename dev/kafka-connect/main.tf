variable "name_prefix" {
  default = "galoy-dev"
}

locals {
  kafka_namespace = "${var.name_prefix}-kafka"
}

resource "helm_release" "kafka_connect" {
  name      = "kafka-connect"
  chart     = "${path.module}/../../charts/kafka-connect"
  namespace = local.kafka_namespace

  dependency_update = true
}

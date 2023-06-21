variable "name_prefix" {
  default = "galoy-dev"
}

locals {
  kafka_namespace    = "${var.name_prefix}-kafka"
  google_credentials = file(pathexpand("~/.config/gcloud/application_default_credentials.json"))
}

resource "kubernetes_secret" "kafka_sa_creds" {
  metadata {
    name      = "kafka-sa-creds"
    namespace = local.kafka_namespace
  }

  data = {
    keyfile = local.google_credentials
  }
}

resource "helm_release" "kafka_connect" {
  name      = "kafka-connect"
  chart     = "${path.module}/../../charts/kafka-connect"
  namespace = local.kafka_namespace

  dependency_update = true
  depends_on        = [kubernetes_secret.kafka_sa_creds]
}

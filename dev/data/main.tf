variable "name_prefix" {}

locals {
  data_namespace = "${var.name_prefix}-data"
}

resource "kubernetes_namespace" "data" {
  metadata {
    name = local.data_namespace
  }
}

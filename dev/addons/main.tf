variable "name_prefix" {}

locals {
  addons_namespace = "${var.name_prefix}-addons"
}

resource "kubernetes_namespace" "addons" {
  metadata {
    name = local.addons_namespace
  }
}


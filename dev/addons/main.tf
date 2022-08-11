variable "name_prefix" {}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
  addons_namespace    = "${var.name_prefix}-addons"
}

resource "kubernetes_namespace" "addons" {
  metadata {
    name = local.addons_namespace
  }
}


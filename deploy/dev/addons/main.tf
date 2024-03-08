variable "name_prefix" {}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
  galoy_namespace     = "${var.name_prefix}-galoy"
  addons_namespace    = "${var.name_prefix}-addons"
  bitcoin_namespace   = "${var.name_prefix}-bitcoin"
}

resource "kubernetes_namespace" "addons" {
  metadata {
    name = local.addons_namespace
  }
}

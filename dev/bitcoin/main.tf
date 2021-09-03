variable "name_prefix" {}

locals {
  bitcoin_namespace    = "${var.name_prefix}-bitcoin"
  bitcoind_rpcpassword = "rpcpassword"
}

resource "kubernetes_namespace" "bitcoin" {
  metadata {
    name = local.bitcoin_namespace
  }
}

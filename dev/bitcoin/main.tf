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

resource "null_resource" "bitcoind_block_generator" {

  provisioner "local-exec" {
    command     = "./bitcoin/generateBlock.sh"
    interpreter = ["sh"]
  }

  depends_on = [helm_release.bitcoind]
}

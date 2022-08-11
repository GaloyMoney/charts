variable "name_prefix" {}

locals {
  smoketest_namespace  = "${var.name_prefix}-smoketest"
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

resource "kubernetes_secret" "bitcoind_smoketest" {
  metadata {
    name      = "bitcoind-smoketest"
    namespace = local.smoketest_namespace
  }

  data = {
    bitcoind_rpcpassword = local.bitcoind_rpcpassword
    bitcoind_endpoint    = "bitcoind.${local.bitcoin_namespace}.svc.cluster.local"
    bitcoind_port        = 18443
    bitcoind_user        = "rpcuser"
  }
}

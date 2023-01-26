variable "name_prefix" {}
variable "bitcoin_network" {}

locals {
  bitcoin_network      = var.bitcoin_network
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

  triggers = {
    run_every_time = timestamp()
  }

  provisioner "local-exec" {
    command     = local.bitcoin_network == "regtest" && local.bitcoin_namespace == "galoy-dev-bitcoin" ? "${path.module}/generateBlock.sh" : "echo Running ${local.bitcoin_network}"
    interpreter = ["sh", "-c"]
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

resource "kubernetes_secret" "fulcrum_smoketest" {
  metadata {
    name      = "fulcrum-smoketest"
    namespace = local.smoketest_namespace
  }

  data = {
    fulcrum_endpoint   = "fulcrum.${local.bitcoin_namespace}.svc.cluster.local"
    fulcrum_stats_port = 8080
  }
}

resource "kubernetes_secret" "lnd_smoketest" {
  metadata {
    name      = "lnd-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    lnd_api_endpoint = "lnd1.${local.bitcoin_namespace}.svc.cluster.local"
    lnd_p2p_endpoint = "lnd1-p2p.${local.bitcoin_namespace}.svc.cluster.local"
  }
}

resource "kubernetes_secret" "loop_smoketest" {
  count = var.bitcoin_network == "signet" ? 0 : 1
  metadata {
    name      = "loop-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    loop_api_endpoint = "loop1.${local.bitcoin_namespace}.svc.cluster.local"
  }
}

resource "kubernetes_secret" "rtl_smoketest" {
  metadata {
    name      = "rtl-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    rtl_endpoint = "rtl.${local.bitcoin_namespace}.svc.cluster.local"
    rtl_port     = 3000
  }
}

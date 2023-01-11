resource "kubernetes_secret" "bitcoind" {
  metadata {
    name      = "bitcoind-rpcpassword"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  data = {
    password = local.bitcoind_rpcpassword
  }
}

resource "helm_release" "bitcoind" {
  name      = "bitcoind"
  chart     = "${path.module}/../../charts/bitcoind"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  values = [
    file("${path.module}/bitcoind-${var.bitcoin_network}-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoind
  ]
}

resource "null_resource" "bitcoind_block_generator" {

  provisioner "local-exec" {
    command     = local.bitcoin_network == "regtest" && local.bitcoin_namespace == "galoy-dev-bitcoin" ? "./bitcoin/generateBlock.sh" : "echo Running ${local.bitcoin_network}"
    interpreter = ["sh", "-c"]
  }

  depends_on = [helm_release.bitcoind]
}

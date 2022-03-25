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
    file("${path.module}/bitcoind-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoind
  ]
}

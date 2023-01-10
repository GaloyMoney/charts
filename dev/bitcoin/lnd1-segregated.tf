resource "helm_release" "lnd-segregated" {
  name      = "lnd1"
  chart     = "${path.module}/../../charts/lnd-segregated"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  dependency_update = true
  timeout           = local.bitcoin_network == "regtest" ? 900 : 9000
  values = [
    file("${path.module}/lnd-segregated-${var.bitcoin_network}-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoind,
    helm_release.bitcoind
  ]
}

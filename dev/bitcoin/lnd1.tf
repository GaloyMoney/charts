resource "kubernetes_secret" "lnd1_wallet" {
  metadata {
    name      = "lnd1-wallet"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  data = {
    "wallet_db"         = filebase64("${path.module}/regtest/lnd1.wallet.db")
    "macaroons_db"      = filebase64("${path.module}/regtest/lnd1.macaroons.db")
    "admin_macaroon"    = filebase64("${path.module}/regtest/lnd1.admin.macaroon")
    "readonly_macaroon" = filebase64("${path.module}/regtest/lnd1.readonly.macaroon")
  }
}

resource "helm_release" "lnd" {
  name      = "lnd1"
  chart     = "${path.module}/../../charts/lnd"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  dependency_update = true
  timeout           = local.bitcoin_network == "regtest" ? 900 : 9000
  values = [
    file("${path.module}/lnd-${var.bitcoin_network}-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoind,
    helm_release.bitcoind
  ]
}

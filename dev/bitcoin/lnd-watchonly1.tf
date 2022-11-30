data "kubernetes_secret" "signer_credentials" {
  metadata {
    name      = "lnd-signer1-credentials"
    namespace = local.signer_namespace
  }
}

resource "kubernetes_secret" "signer_credentials" {
  metadata {
    name      = "lnd-signer1-credentials"
    namespace = local.bitcoin_namespace
  }

  data = data.kubernetes_secret.signer_credentials.data
}

data "kubernetes_secret" "signer_accounts" {
  metadata {
    name      = "lnd-signer1-accounts"
    namespace = local.signer_namespace
  }
}

resource "kubernetes_secret" "signer_accounts" {
  metadata {
    name      = "lnd-signer1-accounts"
    namespace = local.bitcoin_namespace
  }

  data = data.kubernetes_secret.signer_accounts.data
}

resource "helm_release" "lnd-watchonly" {
  name      = "lnd1"
  chart     = "${path.module}/../../charts/lnd-watchonly"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  dependency_update = true
  timeout           = local.bitcoin_network == "regtest" ? 900 : 9000
  values = [
    file("${path.module}/lnd-watchonly-${var.bitcoin_network}-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoind,
    helm_release.bitcoind,
    kubernetes_secret.signer_credentials,
    kubernetes_secret.signer_accounts
  ]
}

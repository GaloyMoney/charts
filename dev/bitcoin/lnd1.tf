resource "kubernetes_secret" "lnd_pg_pass" {
  metadata {
    name      = "postgres-creds"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  data = {
    uri                 = "postgres://postgres:password@lnd1-postgresql:5432/lnd"
    "postgres-password" = "password"
  }
}

data "kubernetes_secret" "signer1_credentials" {
  metadata {
    name      = "signer1-credentials"
    namespace = local.signer_namespace
  }
}

resource "kubernetes_secret" "signer1_credentials" {
  metadata {
    name      = "signer1-credentials"
    namespace = local.bitcoin_namespace
  }

  data = data.kubernetes_secret.signer1_credentials.data
}

data "kubernetes_secret" "signer1_accounts" {
  metadata {
    name      = "signer1-accounts"
    namespace = local.signer_namespace
  }
}

resource "kubernetes_secret" "signer1_accounts" {
  metadata {
    name      = "signer1-accounts"
    namespace = local.bitcoin_namespace
  }

  data = data.kubernetes_secret.signer1_accounts.data
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
    helm_release.bitcoind,
    kubernetes_secret.signer1_credentials
  ]
}

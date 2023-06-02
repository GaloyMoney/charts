resource "random_id" "signer_encryption_key" {
  byte_length = 32
}

resource "kubernetes_secret" "bria_secrets" {
  metadata {
    name      = "bria"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  data = {
    pg-con : "postgres://bria:bria@bria-postgresql:5432/bria"
    signer-encryption-key : random_id.signer_encryption_key.hex
  }
}

resource "helm_release" "bria" {
  name      = "bria"
  chart     = "${path.module}/../../charts/bria"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  values = [
    file("${path.module}/bria-values.yml")
  ]

  depends_on = [
    helm_release.bitcoind_onchain,
    helm_release.fulcrum,
    kubernetes_secret.bria_secrets
  ]

  dependency_update = true
}

resource "kubernetes_secret" "bria_smoketest" {
  metadata {
    name      = "bria-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {}
}

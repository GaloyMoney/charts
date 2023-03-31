resource "kubernetes_secret" "bria_secrets" {
  metadata {
    name      = "bria"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  data = {
    "pg-con" = "postgres://bria:bria@bria-postgresql:5432/bria"
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
    helm_release.bitcoind,
    helm_release.fulcrum,
    helm_release.lnd,
    kubernetes_secret.bria_secrets
  ]

  dependency_update = true
}

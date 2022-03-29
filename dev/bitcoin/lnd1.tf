resource "helm_release" "lnd" {
  name      = "lnd1"
  chart     = "${path.module}/../../charts/lnd"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  dependency_update = true

  values = [
    file("${path.module}/lnd-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoind,
    helm_release.bitcoind
  ]
}

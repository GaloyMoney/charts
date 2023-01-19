
resource "helm_release" "loop" {
  count     = 0
  name      = "loop1"
  chart     = "${path.module}/../../charts/loop"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  dependency_update = true

  values = [
    file("${path.module}/loop-values.yml")
  ]

  depends_on = [
    helm_release.lnd
  ]
}

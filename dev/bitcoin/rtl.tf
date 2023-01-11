resource "helm_release" "rtl" {
  name      = "rtl"
  chart     = "${path.module}/../../charts/rtl"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  dependency_update = true

  depends_on = [
    helm_release.lnd-segregated
  ]
}

resource "helm_release" "galoy_pay" {
  name      = "galoy-pay"
  chart     = "${path.module}/../../charts/galoy-pay"
  namespace = kubernetes_namespace.addons.metadata[0].name
}

resource "helm_release" "galoy_pay" {
  name       = "galoy-pay"
  chart      = "${path.module}/../../charts/galoy-pay"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.addons.metadata[0].name
}

resource "helm_release" "web_wallet" {
  name       = "web-wallet"
  chart      = "${path.module}/../../charts/web-wallet"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.addons.metadata[0].name
}

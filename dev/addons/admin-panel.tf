resource "helm_release" "admin_panel" {
  name       = "admin-panel"
  chart      = "${path.module}/../../charts/admin-panel"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.addons.metadata[0].name
}

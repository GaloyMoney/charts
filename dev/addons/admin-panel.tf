resource "helm_release" "admin_panel" {
  name       = "admin-panel"
  chart      = "${path.module}/../../charts/admin-panel"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.addons.metadata[0].name
}

resource "kubernetes_secret" "admin_panel_smoketest" {
  metadata {
    name      = "admin-panel-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    admin_panel_endpoint = "admin-panel.${local.addons_namespace}.svc.cluster.local"
    admin_panel_port     = 3000
  }
}

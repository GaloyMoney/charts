resource "helm_release" "admin_panel" {
  name       = "admin-panel"
  chart      = "${path.module}/../../charts/admin-panel"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.addons.metadata[0].name

  values = [
    file("${path.module}/admin-panel-values.yml")
  ]
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

resource "kubernetes_secret" "admin_panel" {
  metadata {
    name      = "admin-panel"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = {
    "next-auth-secret" : "dummy123",
    "oauth-client-id" : "dummy",
    "oauth-client-secret" : "dummy"
  }
}

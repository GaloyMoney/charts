resource "helm_release" "galoy_deps" {
  name      = "galoy-deps"
  chart     = "${path.module}/chart"
  namespace = kubernetes_namespace.testflight.metadata[0].name

  dependency_update = true
}

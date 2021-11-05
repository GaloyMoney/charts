
resource "helm_release" "jupyterhub" {
  name      = "jupyter"
  chart     = "jupyterhub/jupyterhub"
  namespace = kubernetes_namespace.data.metadata[0].name

  values = [
    file("${path.module}/config.yaml")
  ]
}

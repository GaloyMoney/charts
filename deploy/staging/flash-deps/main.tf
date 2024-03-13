
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "flash_deps" {
  name = "flash-deps"
  chart = "${path.module}/../../../helm/flash-deps" 
  namespace = kubernetes_namespace.ingress.metadata[0].name
  values = [
    file("${path.module}/staging-values.yaml"),
  ]
}
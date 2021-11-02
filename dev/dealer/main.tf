variable "name_prefix" {}

locals {
  dealer_namespace = "${var.name_prefix}-dealer"
}

resource "kubernetes_namespace" "dealer" {
  metadata {
    name = local.dealer_namespace
  }
}

resource "helm_release" "dealer" {
  name       = "dealer"
  chart      = "${path.module}/../../charts/dealer"
  repository = "https://galoymoney.github.io/charts"
  namespace  = kubernetes_namespace.dealer.metadata[0].name

  values = [
    file("${path.module}/dealer-values.yml")
  ]

  dependency_update = true
}

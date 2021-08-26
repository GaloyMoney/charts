variable "testflight_namespace" {}

resource "kubernetes_namespace" "testflight" {
  metadata {
    name = local.testflight_namespace
  }
}

data "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name = "lnd-credentials"
    namespace = "galoy-staging-bitcoin"
  }
}

resource "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name = "lnd1-credentials"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.lnd1_credentials.data
}

resource "helm_release" "rtl" {
  name       = "rtl"
  chart      = "${path.module}/chart"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.testflight.metadata[0].name

  values = [
    file("${path.module}/testflight-values.yml")
  ]

  depends_on = [
    kubernetes_secret.lnd1_credentials,
  ]
}

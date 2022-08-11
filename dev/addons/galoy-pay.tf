resource "helm_release" "galoy_pay" {
  name      = "galoy-pay"
  chart     = "${path.module}/../../charts/galoy-pay"
  namespace = kubernetes_namespace.addons.metadata[0].name
}

resource "kubernetes_secret" "galoy_pay_smoketest" {
  metadata {
    name      = "galoy-pay-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_pay_endpoint = "galoy-pay.${local.addons_namespace}.svc.cluster.local"
    galoy_pay_port     = 80
  }
}

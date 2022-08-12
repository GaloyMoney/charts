locals {
  session_keys = "session_keys"
}

resource "kubernetes_secret" "web_wallet_secret" {
  metadata {
    name      = "web-wallet"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = {
    "session-keys" : local.session_keys
  }
}

resource "kubernetes_secret" "web_wallet_mobile_secret" {
  metadata {
    name      = "web-wallet-mobile"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = {
    "session-keys" : local.session_keys
  }
}

resource "helm_release" "web_wallet" {
  name      = "web-wallet"
  chart     = "${path.module}/../../charts/web-wallet"
  namespace = kubernetes_namespace.addons.metadata[0].name

  depends_on = [kubernetes_secret.web_wallet_secret]
}

resource "helm_release" "web_wallet_mobile" {
  name      = "web-wallet-mobile"
  chart     = "${path.module}/../../charts/web-wallet"
  namespace = kubernetes_namespace.addons.metadata[0].name

  depends_on = [kubernetes_secret.web_wallet_mobile_secret]

  values = [
    file("${path.module}/web-wallet-mobile-values.yml")
  ]
}

resource "kubernetes_secret" "web_wallet_smoketest" {
  metadata {
    name      = "web-wallet-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    web_wallet_endpoint        = "web-wallet.${local.addons_namespace}.svc.cluster.local"
    web_wallet_mobile_endpoint = "web-wallet-mobile.${local.addons_namespace}.svc.cluster.local"
    web_wallet_port            = 80
  }
}

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

resource "helm_release" "web_wallet" {
  name      = "web-wallet"
  chart     = "${path.module}/../../charts/web-wallet"
  namespace = kubernetes_namespace.addons.metadata[0].name

  depends_on = [kubernetes_secret.web_wallet_secret]
}

resource "helm_release" "web_wallet_mobile_layout" {
  name      = "web-wallet"
  chart     = "${path.module}/../../charts/web-wallet"
  namespace = kubernetes_namespace.addons.metadata[0].name

  depends_on = [kubernetes_secret.web_wallet_secret]

  values = [
    file("${path.module}/web-wallet-mobile-values.yml")
  ]
}

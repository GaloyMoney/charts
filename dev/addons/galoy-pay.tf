resource "helm_release" "galoy_pay" {
  name      = "galoy-pay"
  chart     = "${path.module}/../../charts/galoy-pay"
  namespace = kubernetes_namespace.addons.metadata[0].name

  values = [
    templatefile("${path.module}/galoy-pay-values.yml.tmpl", {})
  ]
}

resource "kubernetes_secret" "galoy_pay_smoketest" {
  metadata {
    name      = "galoy-pay-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_pay_endpoints  = jsonencode(["galoy-pay.${local.addons_namespace}.svc.cluster.local"])
    galoy_pay_port       = 80
    lnurl_check_disabled = "true"
  }
}

data "kubernetes_secret" "redis_creds" {
  metadata {
    name      = "galoy-redis-pw"
    namespace = local.galoy_namespace
  }
}
resource "kubernetes_secret" "redis_creds" {
  metadata {
    name      = "galoy-redis-pw"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = data.kubernetes_secret.redis_creds.data
}

resource "kubernetes_secret" "nostr_private_key" {
  metadata {
    name      = "galoy-nostr-private-key"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = {
    "key" : "bb159f7aaafa75a7d4470307c9d6ea18409d4f082b41abcf6346aaae5b2b3b10"
  }
}

data "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name      = "lnd1-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name      = "lnd-credentials"
    namespace = kubernetes_namespace.addons.metadata[0].name
  }

  data = data.kubernetes_secret.lnd1_credentials.data
}

resource "kubernetes_secret" "bria_secrets" {
  metadata {
    name      = "bria"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  data = {
    "pg-con" = "postgres://bria:bria@bria-postgresql:5432/bria"
  }
}

resource "helm_release" "bria" {
  name      = "bria"
  chart     = "${path.module}/../../charts/bria"
  namespace = kubernetes_namespace.bitcoin.metadata[0].name

  values = [
    file("${path.module}/bria-values.yml")
  ]

  depends_on = [
    helm_release.bitcoind,
    helm_release.fulcrum,
    helm_release.lnd,
    kubernetes_secret.bria_secrets
  ]

  dependency_update = true
}

resource "time_sleep" "wait_10_seconds" {
  depends_on      = [helm_release.bria]
  create_duration = "10s"
}

data "kubernetes_secret" "bria_admin_api_key" {
  metadata {
    name      = "bria-admin-api-key"
    namespace = kubernetes_namespace.bitcoin.metadata[0].name
  }

  depends_on = [
    time_sleep.wait_10_seconds
  ]
}

resource "kubernetes_secret" "bria_smoketest" {
  metadata {
    name      = "bria-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    "bria_admin_api_key" : data.kubernetes_secret.bria_admin_api_key.data["admin-api-key"]
    "bria_admin_api_endpoint" : "bria-admin.${local.bitcoin_namespace}.svc.cluster.local:2743"
    "bria_api_endpoint" : "bria-api.${local.bitcoin_namespace}.svc.cluster.local:2742"
  }
}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
  galoy_namespace     = "${var.name_prefix}-galoy"
}

resource "helm_release" "galoy" {
  name      = "galoy"
  chart     = "${path.module}/../../charts/galoy"
  namespace = kubernetes_namespace.galoy.metadata[0].name

  values = [
    templatefile("${path.module}/galoy-values.yml.tmpl", {
      kratos_pg_host : local.kratos_pg_host,
      kratos_callback_api_key : random_password.kratos_callback_api_key.result
    }),
    file("${path.module}/galoy-${var.bitcoin_network}-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoinrpc_password,
    kubernetes_secret.lnd1_credentials,
    kubernetes_secret.loop1_credentials,
    kubernetes_secret.lnd1_pubkey,
    kubernetes_secret.lnd2_credentials,
    kubernetes_secret.loop2_credentials,
    kubernetes_secret.lnd2_pubkey,
    kubernetes_secret.price_history_postgres_creds,
    kubernetes_secret.kratos_master_user_password,
    helm_release.postgresql
  ]

  dependency_update = true
  timeout           = 900
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = "galoy-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_endpoint         = local.galoy-oathkeeper-proxy-host
    galoy_port             = 4455
    price_history_endpoint = "galoy-price-history.${local.galoy_namespace}.svc.cluster.local"
    price_history_port     = 50052
  }
}

terraform {
  required_providers {
    jose = {
      source  = "bluemill/jose"
      version = "1.0.0"
    }
  }
}

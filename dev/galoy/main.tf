variable "name_prefix" {}
variable "bitcoin_network" {}

locals {
  bitcoin_network     = var.bitcoin_network
  smoketest_namespace = "${var.name_prefix}-smoketest"
  galoy_namespace     = "${var.name_prefix}-galoy"
  bitcoin_namespace   = "${var.name_prefix}-bitcoin"
  bitcoin_secret      = "bitcoind-rpcpassword"
  jwt_secret          = "jwt"

  postgres_database = "price-history"
  postgres_username = "price-history"
  postgres_password = "price-history"
}

resource "kubernetes_namespace" "galoy" {
  metadata {
    name = local.galoy_namespace
  }
}

data "kubernetes_secret" "network" {
  metadata {
    name      = "network"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "network" {
  metadata {
    name      = "network"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.network.data
}

resource "kubernetes_secret" "jwt_secret" {
  metadata {
    name      = "jwt-secret"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    secret = local.jwt_secret
  }
}

resource "kubernetes_secret" "gcs_sa_key" {
  metadata {
    name      = "gcs-sa-key"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {}
}

resource "kubernetes_secret" "geetest_key" {
  metadata {
    name      = "geetest-key"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    key = "dummy"
    id  = "dummy"
  }
}

resource "kubernetes_secret" "mongodb_creds" {
  metadata {
    name      = "galoy-mongodb"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    "mongodb-password" : "password"
    "mongodb-passwords" : "password"
    "mongodb-root-password" : "password"
    "mongodb-replica-set-key" : "replica"
  }
}

resource "kubernetes_secret" "redis_creds" {
  metadata {
    name      = "galoy-redis-pw"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    "redis-password" : "password"
  }
}

resource "kubernetes_secret" "dropbox_access_token" {
  metadata {
    name      = "dropbox-access-token"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    token = ""
  }
}

resource "kubernetes_secret" "twilio_secret" {
  metadata {
    name      = "twilio-secret"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    TWILIO_VERIFY_SERVICE_ID = "dummy"
    TWILIO_ACCOUNT_SID       = "ACdummy"
    TWILIO_AUTH_TOKEN        = "dummy"
  }
}

data "kubernetes_secret" "bitcoin_rpcpassword" {
  metadata {
    name      = local.bitcoin_secret
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "bitcoinrpc_password" {
  metadata {
    name      = "bitcoind-rpcpassword"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.bitcoin_rpcpassword.data
}

data "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name      = "lnd1-pubkey"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name      = "lnd2-pubkey"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.lnd2_pubkey.data
}

data "kubernetes_secret" "lnd1_pubkey" {
  metadata {
    name      = "lnd1-pubkey"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd1_pubkey" {
  metadata {
    name      = "lnd1-pubkey"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.lnd1_pubkey.data
}

data "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name      = "lnd1-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name      = "lnd2-credentials"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.lnd2_credentials.data
}

data "kubernetes_secret" "loop2_credentials" {
  metadata {
    name      = "loop1-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "loop2_credentials" {
  metadata {
    name      = "loop2-credentials"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.loop2_credentials.data
}

data "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name      = "lnd1-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name      = "lnd1-credentials"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.lnd1_credentials.data
}

data "kubernetes_secret" "loop1_credentials" {
  metadata {
    name      = "loop1-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "loop1_credentials" {
  metadata {
    name      = "loop1-credentials"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = data.kubernetes_secret.loop1_credentials.data
}

resource "jose_keyset" "oathkeeper" {}

resource "kubernetes_secret" "oathkeeper" {
  metadata {
    name      = "galoy-oathkeeper"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    "mutator.id_token.jwks.json" = jsonencode({
      keys = [jsondecode(jose_keyset.oathkeeper.private_key)]
    })
  }
}


resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.galoy.metadata[0].name

  values = [
    file("${path.module}/postgresql-values.yml")
  ]
}

resource "random_password" "kratos_callback_api_key" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "kratos_master_user_password" {
  metadata {
    name      = "kratos-secret"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    "master_user_password" = random_password.kratos_master_user_password.result
    "callback_api_key"     = random_password.kratos_callback_api_key.result
  }
}

resource "helm_release" "galoy" {
  name      = "galoy"
  chart     = "${path.module}/../../charts/galoy"
  namespace = kubernetes_namespace.galoy.metadata[0].name

  values = [
    templatefile("${path.module}/kratos-values.yml.tmpl", {
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

resource "kubernetes_secret" "price_history_postgres_creds" {
  metadata {
    name      = "galoy-price-history-postgres-creds"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    username = local.postgres_username
    password = local.postgres_password
    database = local.postgres_database
  }
}

resource "random_password" "kratos_master_user_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = "galoy-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_endpoint         = "galoy-oathkeeper-proxy.${local.galoy_namespace}.svc.cluster.local"
    galoy_port             = 4455
    price_history_endpoint = "galoy-price-history.${local.galoy_namespace}.svc.cluster.local"
    price_history_port     = 50052
    kratos_admin_endpoint  = "galoy-kratos-admin.${local.galoy_namespace}.svc.cluster.local"
    kratos_admin_port      = 80
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

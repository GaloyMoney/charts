variable "testflight_namespace" {}
variable "smoketest_kubeconfig" {}
variable "testflight_backups_creds" {}

locals {
  cluster_name     = "galoy-staging-cluster"
  cluster_location = "us-east1"
  gcp_project      = "galoy-staging"

  smoketest_namespace  = "galoy-staging-smoketest"
  bitcoin_namespace    = "galoy-staging-bitcoin"
  testflight_namespace = var.testflight_namespace
  smoketest_kubeconfig = var.smoketest_kubeconfig
  backups_sa_creds     = var.testflight_backups_creds

  testflight_api_host = "galoy-oathkeeper-proxy.${local.testflight_namespace}.svc.cluster.local"
  kratos_admin_host   = "galoy-kratos-admin.${local.testflight_namespace}.svc.cluster.local"

  postgres_database = "price-history"
  postgres_username = "price-history"
  postgres_password = "price-history"

  test_account_number = yamldecode(file("${path.module}/testflight-values.yml")).galoy.config.test_accounts[0].phone
  code                = yamldecode(file("${path.module}/testflight-values.yml")).galoy.config.test_accounts[0].code
  tag                 = yamldecode(file("${path.module}/testflight-values.yml")).galoy.config.test_accounts[0].username
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
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.network.data
}

resource "kubernetes_secret" "gcs_sa_key" {
  metadata {
    name      = "gcs-sa-key"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    "gcs-sa-key.json" : local.backups_sa_creds
  }
}

resource "kubernetes_secret" "geetest_key" {
  metadata {
    name      = "geetest-key"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    key = "geetest_key"
    id  = "geetest_id"
  }
}

resource "kubernetes_secret" "dropbox_access_token" {
  metadata {
    name      = "dropbox-access-token"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    token = ""
  }
}

resource "kubernetes_secret" "mongodb_creds" {
  metadata {
    name      = "galoy-mongodb"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    "mongodb-password" : "password"
    "mongodb-passwords" : "password"
    "mongodb-root-password" : "password"
    "mongodb-replica-set-key" : "replica"
  }
}

resource "kubernetes_secret" "twilio_secret" {
  metadata {
    name      = "twilio-secret"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    TWILIO_VERIFY_SERVICE_ID = ""
    TWILIO_ACCOUNT_SID       = ""
    TWILIO_AUTH_TOKEN        = ""
  }
}

resource "kubernetes_secret" "jwt_secret" {
  metadata {
    name      = "jwt-secret"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    secret = "jwt-secret"
  }
}

data "kubernetes_secret" "bitcoin_rpcpassword" {
  metadata {
    name      = "bitcoind-rpcpassword"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "bitcoinrpc_password" {
  metadata {
    name      = "bitcoind-rpcpassword"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.bitcoin_rpcpassword.data
}

data "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name      = "lnd2-pubkey"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name      = "lnd2-pubkey"
    namespace = kubernetes_namespace.testflight.metadata[0].name
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
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.lnd1_pubkey.data
}

data "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name      = "lnd2-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name      = "lnd2-credentials"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.lnd2_credentials.data
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
    namespace = kubernetes_namespace.testflight.metadata[0].name
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
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.loop1_credentials.data
}

data "kubernetes_secret" "loop2_credentials" {
  metadata {
    name      = "loop2-credentials"
    namespace = local.bitcoin_namespace
  }
}

resource "kubernetes_secret" "loop2_credentials" {
  metadata {
    name      = "loop2-credentials"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.loop2_credentials.data
}

resource "kubernetes_secret" "test_accounts" {
  metadata {
    name      = "test-accounts"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }
  data = {
    json = jsonencode([
      {
        phone = local.test_account_number
        code  = local.code
        tag   = local.tag
      }
    ])
  }
}

resource "kubernetes_namespace" "testflight" {
  metadata {
    name = local.testflight_namespace
  }
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = local.testflight_namespace
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_endpoint         = local.testflight_api_host
    galoy_port             = 4455
    price_history_endpoint = "galoy-price-history.${local.testflight_namespace}.svc.cluster.local"
    price_history_port     = 50052
    kratos_admin_endpoint  = local.kratos_admin_host
    kratos_admin_port      = 80

    test_accounts = kubernetes_secret.test_accounts.data.json
  }
}

resource "kubernetes_secret" "price_history_postgres_creds" {
  metadata {
    name      = "galoy-price-history-postgres-creds"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    username = local.postgres_username
    password = local.postgres_password
    database = local.postgres_database
  }
}

resource "random_password" "redis" {
  length  = 20
  special = false
}

resource "kubernetes_secret" "redis_password" {
  metadata {
    name      = "galoy-redis"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    "redis-password" : random_password.redis.result
  }
}

resource "jose_keyset" "oathkeeper" {}

resource "kubernetes_secret" "oathkeeper" {
  metadata {
    name      = "galoy-oathkeeper"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    "mutator.id_token.jwks.json" = jsonencode({
      keys = [jsondecode(jose_keyset.oathkeeper.private_key)]
    })
  }
}

resource "random_password" "kratos_master_user_password" {
  length  = 32
  special = false
}

resource "random_password" "kratos_callback_api_key" {
  length = 32
}

resource "kubernetes_secret" "kratos_master_user_password" {
  metadata {
    name      = "kratos-secret"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    "master_user_password" = random_password.kratos_master_user_password.result
    "callback_api_key"     = random_password.kratos_callback_api_key.result
  }
}

resource "helm_release" "galoy" {
  name       = "galoy"
  chart      = "${path.module}/chart"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.testflight.metadata[0].name

  values = [file("${path.module}/testflight-values.yml")]

  depends_on = [
    kubernetes_secret.bitcoinrpc_password,
    kubernetes_secret.lnd1_credentials,
    kubernetes_secret.loop1_credentials,
    kubernetes_secret.lnd1_pubkey,
    kubernetes_secret.lnd2_credentials,
    kubernetes_secret.loop2_credentials,
    kubernetes_secret.lnd2_pubkey,
    kubernetes_secret.price_history_postgres_creds
  ]

  dependency_update = true
}

data "google_container_cluster" "primary" {
  project  = local.gcp_project
  name     = local.cluster_name
  location = local.cluster_location
}

data "google_client_config" "default" {
  provider = google-beta
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "kubernetes-alpha" {
  host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
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

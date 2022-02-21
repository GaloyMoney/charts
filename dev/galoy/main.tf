variable "name_prefix" {}

locals {
  galoy_namespace     = "${var.name_prefix}-galoy"
  bitcoin_namespace   = "${var.name_prefix}-bitcoin"
  addons_namespace    = "${var.name_prefix}-addons"
  bitcoin_secret      = "bitcoind-rpcpassword"
  dev_apollo_key      = "dev_apollo_key"
  dev_apollo_graph_id = "dev_apollo_graph_id"
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
    "mongodb-root-password" : "password"
    "mongodb-replica-set-key" : "replica"
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
    TWILIO_PHONE_NUMBER = ""
    TWILIO_ACCOUNT_SID  = ""
    TWILIO_AUTH_TOKEN   = ""
  }
}

resource "kubernetes_secret" "price_secret" {
  metadata {
    name      = "price-secret"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    port = "50055"
    host = "dealer-price.${local.addons_namespace}.svc.cluster.local"
  }
}

resource "kubernetes_secret" "apollo_secret" {
  metadata {
    name      = "galoy-apollo-secret"
    namespace = kubernetes_namespace.galoy.metadata[0].name
  }

  data = {
    key = local.dev_apollo_key
    id  = local.dev_apollo_graph_id
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

resource "helm_release" "galoy" {
  name      = "galoy"
  chart     = "${path.module}/../../charts/galoy"
  namespace = kubernetes_namespace.galoy.metadata[0].name

  values = [
    file("${path.module}/galoy-values.yml")
  ]

  depends_on = [
    kubernetes_secret.bitcoinrpc_password,
    kubernetes_secret.lnd1_credentials,
    kubernetes_secret.lnd1_pubkey,
    kubernetes_secret.lnd2_credentials,
    kubernetes_secret.lnd2_pubkey
  ]

  dependency_update = true
}

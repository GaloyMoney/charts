variable "testflight_namespace" {}

locals {
  cluster_name             = "galoy-staging-cluster"
  cluster_location         = "us-east1"
  gcp_project              = "galoy-staging"

  testflight_namespace = var.testflight_namespace
}

data "kubernetes_secret" "network" {
  metadata {
    name = "network"
    namespace = "galoy-staging-bitcoin"
  }
}

resource "kubernetes_secret" "network" {
  metadata {
    name = "network"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.network.data
}

resource "kubernetes_secret" "twilio_secret" {
  metadata {
    name = "twilio-secret"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {}
}

data "kubernetes_secret" "bitcoin_rpcpassword" {
  metadata {
    name = "bitcoind-rpcpassword"
    namespace = "galoy-staging-bitcoin"
  }
}

resource "kubernetes_secret" "bitcoinrpc_password" {
  metadata {
    name = "bitcoind-rpcpassword"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.bitcoin_rpcpassword.data
}

data "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name = "lnd-pubkey"
    namespace = "galoy-staging-bitcoin"
  }
}

resource "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name = "lnd2-pubkey"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.lnd2_pubkey.data
}

data "kubernetes_secret" "lnd1_pubkey" {
  metadata {
    name = "lnd-pubkey"
    namespace = "galoy-staging-bitcoin"
  }
}

resource "kubernetes_secret" "lnd1_pubkey" {
  metadata {
    name = "lnd1-pubkey"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.lnd1_pubkey.data
}

data "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name = "lnd-credentials"
    namespace = "galoy-staging-bitcoin"
  }
}

resource "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name = "lnd2-credentials"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = data.kubernetes_secret.lnd2_credentials.data
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

resource "kubernetes_namespace" "testflight" {
  metadata {
    name = local.testflight_namespace
  }
}

resource "helm_release" "galoy" {
  name       = "galoy"
  chart      = "${path.module}/chart"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.testflight.metadata[0].name

  values = [
    file("${path.module}/testflight-values.yml")
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

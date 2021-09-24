variable "testflight_namespace" {}
variable "bitcoind_rpcpassword" {}

locals {
  cluster_name             = "galoy-staging-cluster"
  cluster_location         = "us-east1"
  gcp_project              = "galoy-staging"

  smoketest_namespace = "galoy-staging-smoketest"
  testflight_namespace = var.testflight_namespace
}

resource "kubernetes_namespace" "testflight" {
  metadata {
    name = local.testflight_namespace
  }
}

resource "kubernetes_secret" "testflight" {
  metadata {
    name = "bitcoind-rpcpassword"
    namespace  = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    password = var.bitcoind_rpcpassword
  }
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name = local.testflight_namespace
    namespace = local.smoketest_namespace
  }
  data = {
    bitcoind_rpcpassword = var.bitcoind_rpcpassword
    bitcoind_endpoint = "bitcoind.${local.testflight_namespace}.svc.cluster.local"
    bitcoind_port = 18332
    bitcoind_user = "rpcuser"
  }
}

resource "helm_release" "bitcoind" {
  name       = "bitcoind"
  chart      = "${path.module}/chart"
  repository = "https://galoymoney.github.io/charts/"
  namespace  = kubernetes_namespace.testflight.metadata[0].name

  values = [
    file("${path.module}/testflight-values.yml")
  ]

  depends_on = [
    kubernetes_secret.testflight
  ]
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

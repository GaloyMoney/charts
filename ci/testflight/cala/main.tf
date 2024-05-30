variable "testflight_namespace" {}

locals {
  cluster_name     = "galoy-staging-cluster"
  cluster_location = "us-east1"
  gcp_project      = "galoy-staging"

  smoketest_namespace  = "galoy-staging-smoketest"
  testflight_namespace = var.testflight_namespace

}

resource "kubernetes_namespace" "testflight" {
  metadata {
    name = local.testflight_namespace
  }
}

resource "random_password" "postgresql" {
  length  = 20
  special = false
}

resource "kubernetes_secret" "cala" {
  metadata {
    name      = "cala"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    pg-user-pw : random_password.postgresql.result
    pg-con : "postgres://cala:${random_password.postgresql.result}@cala-postgresql:5432/cala"
  }
}

resource "helm_release" "cala" {
  name      = "cala"
  chart     = "${path.module}/chart"
  namespace = kubernetes_namespace.testflight.metadata[0].name

  values = [
    templatefile("${path.module}/testflight-values.yml.tmpl")
  ]

  depends_on = [kubernetes_secret.cala]

  dependency_update = true
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = local.testflight_namespace
    namespace = local.smoketest_namespace
  }
  data = {}
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

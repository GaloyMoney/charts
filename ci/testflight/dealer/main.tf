variable "testflight_namespace" {}

locals {
  cluster_name     = "galoy-staging-cluster"
  cluster_location = "us-east1"
  gcp_project      = "galoy-staging"

  smoketest_namespace  = "galoy-staging-smoketest"
  galoy_namespace      = "galoy-staging-galoy"
  testflight_namespace = var.testflight_namespace

  postgres_password   = "postgres"
  postgres_db_uri     = "postgres://postgres:postgres@dealer-postgresql:5432/dealer"
  okex5_key           = "key"
  okex5_secret        = "secret"
  okex5_password      = "pwd"
  okex5_fund_password = "none"
}

resource "kubernetes_namespace" "testflight" {
  metadata {
    name = local.testflight_namespace
  }
}

resource "kubernetes_secret" "okex5_creds" {
  metadata {
    name      = "dealer-okex5"
    namespace = local.testflight_namespace
  }

  data = {
    "okex5_key" : local.okex5_key
    "okex5_secret" : local.okex5_secret
    "okex5_password" : local.okex5_password
    "okex5_fund_password" : local.okex5_fund_password
  }
}

resource "kubernetes_secret" "postgres_creds" {
  metadata {
    name      = "dealer-postgres"
    namespace = local.testflight_namespace
  }

  data = {
    "postgresql-password" : local.postgres_password
    "postgresql-db-uri" : local.postgres_db_uri
  }
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = local.testflight_namespace
    namespace = local.smoketest_namespace
  }
  data = {
    dealer_endpoint = "dealer.${local.testflight_namespace}.svc.cluster.local"
    dealer_port     = 3333
  }
}

data "kubernetes_secret" "dealer_creds" {
  metadata {
    name      = "dealer-creds"
    namespace = local.galoy_namespace
  }
}

resource "kubernetes_secret" "dealer_creds" {
  metadata {
    name      = "dealer-creds"
    namespace = local.testflight_namespace
  }

  data = data.kubernetes_secret.dealer_creds.data
}

resource "helm_release" "dealer" {
  name      = "dealer"
  chart     = "${path.module}/chart"
  namespace = kubernetes_namespace.testflight.metadata[0].name

  depends_on = [
    kubernetes_secret.postgres_creds,
    kubernetes_secret.okex5_creds,
    kubernetes_secret.dealer_creds
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
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.64.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.64.0"
    }
  }
}

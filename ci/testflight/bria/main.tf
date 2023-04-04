variable "testflight_namespace" {}

locals {
  cluster_name     = "galoy-staging-cluster"
  cluster_location = "us-east1"
  gcp_project      = "galoy-staging"

  smoketest_namespace  = "galoy-staging-smoketest"
  bitcoin_namespace    = "galoy-staging-bitcoin"
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

resource "kubernetes_secret" "bria" {
  metadata {
    name      = "bria"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  data = {
    pg-user-pw : random_password.postgresql.result
    pg-con = "postgres://bria:${random_password.postgresql.result}@bria-postgresql:5432/bria"
  }
}

resource "helm_release" "bria" {
  name      = "bria"
  chart     = "${path.module}/chart"
  namespace = kubernetes_namespace.testflight.metadata[0].name

  values = [
    file("${path.module}/testflight-values.yml")
  ]

  depends_on = [kubernetes_secret.bria]

  dependency_update = true
}

resource "time_sleep" "wait_10_seconds" {
  depends_on      = [helm_release.bria]
  create_duration = "10s"
}

data "kubernetes_secret" "bria_admin_api_key" {
  metadata {
    name      = "bria-admin-api-key"
    namespace = kubernetes_namespace.testflight.metadata[0].name
  }

  depends_on = [time_sleep.wait_10_seconds]
}

resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = local.testflight_namespace
    namespace = local.smoketest_namespace
  }
  data = {
    "bria_admin_api_key" : data.kubernetes_secret.bria_admin_api_key.data["admin-api-key"]
    "bria_admin_api_endpoint" : "bria-admin.${local.testflight_namespace}.svc.cluster.local:2743"
    "bria_api_endpoint" : "bria-api.${local.testflight_namespace}.svc.cluster.local:2742"
  }
}

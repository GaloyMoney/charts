variable "name_prefix" {
  default = "galoy-dev"
}

variable "okex_secret_key" {}
variable "okex_passphrase" {}
variable "galoy_phone_code" {}
variable "galoy_phone_number" {}
variable "okex_api_key" {}

locals {
  stablesats_namespace = "${var.name_prefix}-stablesats"
}

resource "kubernetes_namespace" "stablesats" {
  metadata {
    name = local.stablesats_namespace
  }
}

resource "random_password" "redis" {
  length  = 20
  special = false
}

resource "random_password" "postgresql" {
  length  = 20
  special = false
}

resource "kubernetes_secret" "stablesats_secrets" {
  metadata {
    name      = "stablesats"
    namespace = kubernetes_namespace.stablesats.metadata[0].name
  }

  data = {
    redis-password : random_password.redis.result
    pg-user-pw : random_password.postgresql.result
    pg-con : "postgres://stablesats:${random_password.postgresql.result}@stablesats-postgresql:5432/stablesats"
    okex-secret-key : var.okex_secret_key
    okex-passphrase : var.okex_passphrase
    galoy-phone-code : var.galoy_phone_code
  }
}

resource "helm_release" "stablesats" {
  name      = "stablesats"
  chart     = "${path.module}/../../charts/stablesats"
  namespace = kubernetes_namespace.stablesats.metadata[0].name

  values = [
    templatefile("${path.module}/stablesats-values.yml.tmpl", {
      galoy_phone_number : var.galoy_phone_number,
      okex_api_key : var.okex_api_key
    })
  ]

  dependency_update = true
}

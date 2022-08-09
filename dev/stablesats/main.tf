variable "name_prefix" {
  default = "galoy-dev"
}

locals {
  stablesats_namespace     = "${var.name_prefix}-stablesats"
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

resource "kubernetes_secret" "redis_password" {
  metadata {
    name      = "stablesats-redis"
    namespace = kubernetes_namespace.stablesats.metadata[0].name
  }

  data = {
    "redis-password" : random_password.redis.result
  }
}

resource "helm_release" "stablesats" {
  name      = "stablesats"
  chart     = "${path.module}/../../charts/stablesats"
  namespace = kubernetes_namespace.stablesats.metadata[0].name

  values = [
    file("${path.module}/stablesats-values.yml")
  ]

  dependency_update = true
}

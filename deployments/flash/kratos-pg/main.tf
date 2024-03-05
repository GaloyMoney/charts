variable "namespace" {
  description = "The Kratos namespace"
}

resource "random_password" "kratos_master_user_password" {
  length  = 32
  special = false
}

resource "random_password" "kratos_callback_api_key" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "kratos_master_user_password" {
  metadata {
    name      = "kratos-secret"
    namespace = var.namespace
  }

  data = {
    "master_user_password" = random_password.kratos_master_user_password.result
    "callback_api_key"     = random_password.kratos_callback_api_key.result
  }
}

resource "helm_release" "kratos_pg" {
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  name       = "kratos-pg"
  namespace  = var.namespace

  values = [
    file("${path.module}/pg-values.yaml")
  ]
}

output "values" {
  value = templatefile("${path.module}/kratos-values.yml.tmpl", {
    kratos_pg_host          = "kratos-pg-postgresql.${var.namespace}.svc.cluster.local"
    kratos_callback_api_key = random_password.kratos_callback_api_key.result
  }) 
}
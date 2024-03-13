
locals {
  namespace                   = "flash"
  flash-oathkeeper-proxy-host = "flash-oathkeeper-proxy.${local.namespace}.svc.cluster.local"
  helm_charts                 = "${path.module}/../../helm"
  flash_chart                 = "${local.helm_charts}/flash"
  pay_chart                   = "${local.helm_charts}/flash-pay"
  #smoketest_namespace = "${var.name_prefix}-smoketest"
}

resource "kubernetes_namespace" "flash" {
  metadata {
    name = local.namespace
  }
}

module "secrets" {
  source = "./secrets"

  # would be nice to internalize these to secrets directory
  TWILIO_ACCOUNT_SID = var.TWILIO_ACCOUNT_SID
  TWILIO_AUTH_TOKEN = var.TWILIO_AUTH_TOKEN
  TWILIO_VERIFY_SERVICE_ID = var.TWILIO_VERIFY_SERVICE_ID
  IBEX_PASSWORD = var.IBEX_PASSWORD
  namespace = kubernetes_namespace.flash.metadata[0].name
}


module "kratos_pg" {
  source = "./kratos-pg"
  namespace = kubernetes_namespace.flash.metadata[0].name
}

resource "helm_release" "flash" {
  name      = "flash"
  chart     = local.flash_chart 
  namespace = kubernetes_namespace.flash.metadata[0].name

  values = [
    module.kratos_pg.values,
    file("${local.flash_chart}/staging.yaml"),
  ]

  depends_on = [
    module.kratos_pg,
    module.secrets
  ]

  dependency_update = true
  timeout           = 360
}

resource "helm_release" "flash-pay" {
  name = "flash-pay"
  chart = local.pay_chart
  namespace = kubernetes_namespace.flash.metadata[0].name
  values = [
    file("${local.pay_chart}/staging-values.yaml"),
  ]
}

module "flash-deps" {
  source = "./flash-deps"
}

# module "cert-manager" {
#   source = "./cert-manager"
# }

#### START CLUSTER REQUIREMENTS? ####
# provider "kubernetes" {
#   host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
# }
# provider "kubernetes-alpha" {
#   host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
# }

# provider "helm" {
#   kubernetes {
#     host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
#     token                  = data.google_client_config.default.access_token
#     cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
#   }
# }
#### END CLUSTER REQUIREMENTS? ####

provider "kubernetes" {
  config_path    = "~/.kube/config"  # Path to your kubeconfig file
  config_context = "do-nyc1-flashcluster"  # Name of the Kubernetes context to use
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "do-nyc1-flashcluster"  # Name of the Kubernetes context to use
 }
}

# to secrets?
# terraform {
#   required_providers {
#     jose = {
#       source  = "bluemill/jose"
#       version = "1.0.0"
#     }
#   }
# }

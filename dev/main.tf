locals {
  name_prefix              = "galoy-dev"
  letsencrypt_issuer_email = "dev@galoy.io"
}

module "infra_services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=1b82786"

  name_prefix              = local.name_prefix
  letsencrypt_issuer_email = local.letsencrypt_issuer_email
  local_deploy             = true
  cluster_endpoint         = "dummy"
  cluster_ca_cert          = "dummy"
}

module "bitcoin" {
  source = "./bitcoin"

  name_prefix = local.name_prefix
}

module "galoy" {
  source = "./galoy"

  name_prefix = local.name_prefix

  depends_on = [
    module.bitcoin
  ]
}

module "monitoring" {
  source = "./monitoring"

  name_prefix       = local.name_prefix
}

module "data" {
  source = "./data"

  name_prefix       = local.name_prefix
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
}

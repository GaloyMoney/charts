variable "bitcoin_network" {}
variable "name_prefix" {}

locals {
  bitcoin_network          = var.bitcoin_network
  name_prefix              = var.name_prefix
  letsencrypt_issuer_email = "dev@galoy.io"
}

module "infra_services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=86b0906"

  name_prefix                 = local.name_prefix
  letsencrypt_issuer_email    = local.letsencrypt_issuer_email
  local_deploy                = true
  cluster_endpoint            = "dummy"
  cluster_ca_cert             = "dummy"
  honeycomb_api_key           = "dummy"
  kubemonkey_notification_url = "dummy"
}

module "galoy_deps" {
  source = "./galoy-deps"
}

module "bitcoin" {
  source = "./bitcoin"

  bitcoin_network = local.bitcoin_network
  name_prefix     = local.name_prefix

  depends_on = [
    module.galoy_deps
  ]
}

module "galoy" {
  source = "./galoy"

  bitcoin_network = local.bitcoin_network
  name_prefix     = local.name_prefix

  depends_on = [
    module.bitcoin
  ]
}

module "monitoring" {
  source = "./monitoring"

  name_prefix = local.name_prefix
}

module "addons" {
  source = "./addons"

  name_prefix = local.name_prefix

  depends_on = [
    module.galoy
  ]
}

module "auth" {
  source = "./auth"

  name_prefix = local.name_prefix
}

module "smoketest" {
  source = "./smoketest"

  name_prefix = local.name_prefix
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
}

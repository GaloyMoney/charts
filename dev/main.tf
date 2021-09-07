locals {
  name_prefix              = "galoy-dev"
  letsencrypt_issuer_email = "dev@galoy.io"
}

module "infra_services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=42dddf5"

  name_prefix              = local.name_prefix
  letsencrypt_issuer_email = local.letsencrypt_issuer_email
}

module "bitcoin" {
  source = "./bitcoin"

  name_prefix = local.name_prefix
}

module "galoy" {
  source = "./galoy"

  name_prefix = local.name_prefix
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
}

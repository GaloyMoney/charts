locals {
  name_prefix = "galoy-dev"
  letsencrypt_issuer_email = "dev@galoy.io"
}

module "infra_services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=9e9fb7b"

  name_prefix              = local.name_prefix
  letsencrypt_issuer_email = local.letsencrypt_issuer_email
}

variable "bitcoin_network" {}
variable "name_prefix" {}

locals {
  bitcoin_network = var.bitcoin_network
  name_prefix     = var.name_prefix
}

module "galoy_deps" {
  source = "./galoy-deps"

  name_prefix = local.name_prefix
}

module "infra_services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/smoketest/gcp?ref=13b2ef9"

  name_prefix      = local.name_prefix
  cluster_endpoint = "dummy"
  cluster_ca_cert  = "dummy"
}

module "kafka_connect" {
  source = "./kafka-connect"

  name_prefix = local.name_prefix

  depends_on = [
    module.galoy_deps,
    module.infra_services
  ]
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

module "smoketest" {
  source = "./smoketest"

  name_prefix = local.name_prefix
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
}

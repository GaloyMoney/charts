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

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
}

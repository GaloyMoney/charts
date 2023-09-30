resource "kubernetes_secret" "smoketest" {
  metadata {
    name      = "galoy-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    galoy_endpoint         = local.galoy-oathkeeper-proxy-host
    galoy_port             = 4455
    price_history_endpoint = "galoy-price-history.${local.galoy_namespace}.svc.cluster.local"
    price_history_port     = 50052
  }
}

terraform {
  required_providers {
    jose = {
      source  = "bluemill/jose"
      version = "1.0.0"
    }
  }
}

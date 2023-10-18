resource "kubernetes_secret" "fulcrum_smoketest" {
  metadata {
    name      = "fulcrum-smoketest"
    namespace = local.smoketest_namespace
  }

  data = {
    fulcrum_endpoint   = "fulcrum.${local.bitcoin_namespace}.svc.cluster.local"
    fulcrum_stats_port = 8080
  }
}

resource "kubernetes_secret" "bria_smoketest" {
  metadata {
    name      = "bria-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {}
}


resource "kubernetes_secret" "mempool_smoketest" {
  metadata {
    name      = "mempool-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    mempool_endpoint = "mempool.${local.bitcoin_namespace}.svc.cluster.local"
    mempool_port     = 8999
  }
}



resource "kubernetes_secret" "rtl_smoketest" {
  metadata {
    name      = "rtl-smoketest"
    namespace = local.smoketest_namespace
  }
  data = {
    rtl_endpoint = "rtl.${local.bitcoin_namespace}.svc.cluster.local"
    rtl_port     = 3000
  }
}

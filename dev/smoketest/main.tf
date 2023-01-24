variable "name_prefix" {}

locals {
  smoketest_namespace = "${var.name_prefix}-smoketest"
}

resource "kubernetes_persistent_volume_claim" "smoketest_tasks" {
  metadata {
    name      = "smoketest-tasks-pv-claim"
    namespace = local.smoketest_namespace
  }
  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.smoketest_tasks.metadata.0.name
  }
}

resource "kubernetes_persistent_volume" "smoketest_tasks" {
  metadata {
    name = "smoketest-tasks-pv-volume"
  }
  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/charts"
      }
    }
  }
}

resource "kubernetes_pod" "smoketest" {
  metadata {
    name      = "smoketest"
    namespace = local.smoketest_namespace

    labels = {
      "allow-to-bitcoind" : "true"
    }
  }

  spec {
    container {
      image             = "us.gcr.io/galoy-org/galoy-deployments-pipeline"
      image_pull_policy = "IfNotPresent"
      name              = "smoketest"

      command = [
        "sleep",
        "604800"
      ]

      volume_mount {
        mount_path = "/charts"
        name       = "smoketest-tasks-pv-storage"
      }
    }

    volume {
      name = "smoketest-tasks-pv-storage"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.smoketest_tasks.metadata.0.name
      }
    }

    service_account_name = "smoketest"
  }
}

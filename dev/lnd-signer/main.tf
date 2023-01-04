variable "name_prefix" {}
variable "bitcoin_network" {}

locals {
  signer_namespace = "${var.name_prefix}-signer"
}

resource "kubernetes_namespace" "signer" {
  metadata {
    name = local.signer_namespace
  }
}

resource "helm_release" "lnd-signer" {
  name      = "lnd-signer2"
  chart     = "${path.module}/../../charts/lnd-segregated"
  namespace = kubernetes_namespace.signer.metadata[0].name

  dependency_update = true
  timeout           = 300
  values = [
    file("${path.module}/lnd-signer-${var.bitcoin_network}-values.yml")
  ]
}

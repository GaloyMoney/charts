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

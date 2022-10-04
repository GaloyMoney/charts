resource "helm_release" "signer" {
  name      = "signer1"
  chart     = "${path.module}/../../charts/signer"
  namespace = kubernetes_namespace.signer.metadata[0].name

  dependency_update = true
  timeout           = 300
  values = [
    file("${path.module}/signer-${var.bitcoin_network}-values.yml")
  ]
}

resource "kubernetes_namespace" "kubemonkey" {
  metadata {
    name = local.kubemonkey_namespace
  }
}

locals {
  ns1 = "test"
  ns2 = "test2"

  kubemonkey_namespace        = "${var.name_prefix}-kubemonkey"
  kubemonkey_time_zone        = "Etc/UTC"
  kubemonkey_notification_url = "dummy"
  kubemonkey_whitelisted_namespaces = [
    local.ns1,
    local.ns2
  ]
}

resource "helm_release" "kubemonkey" {
  name      = "kubemonkey"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace = kubernetes_namespace.kubemonkey.metadata[0].name

  values = [
    templatefile("${path.module}/kubemonkey-values.yml.tmpl", {
      time_zone : local.kubemonkey_time_zone
      whitelisted_namespaces : local.kubemonkey_whitelisted_namespaces
      notification_url : local.kubemonkey_notification_url
    })
  ]

  dependency_update = true
}

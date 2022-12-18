locals {
  letsencrypt_issuer_email = "dev@galoy.io"
  local_deploy             = "true"
  ingress_namespace        = "${var.name_prefix}-ingress"
  ingress_service_name     = "${var.name_prefix}-ingress"
  jaeger_host              = "opentelemetry-collector.${local.otel_namespace}.svc.cluster.local"
  enable_tracing           = true
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = local.ingress_namespace
    labels = {
      type = "ingress-nginx"
    }
  }
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  values = [
    file("${path.module}/cert-manager-values.yml.tmpl")
  ]

  depends_on = [
    helm_release.kafka
  ]
}

resource "helm_release" "ingress_nginx" {
  name      = "ingress-nginx"
  chart     = "${path.module}/../../charts/galoy-deps"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  values = [
    templatefile("${path.module}/ingress-values.yml.tmpl", {
      service_type = local.local_deploy ? "NodePort" : "LoadBalancer"
      jaeger_host  = local.jaeger_host
      service_name = local.ingress_service_name
      enable_tracing = local.enable_tracing
    })
  ]

  depends_on = [
    helm_release.cert_manager,
  ]
}

resource "kubernetes_manifest" "issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-issuer"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = local.letsencrypt_issuer_email
        privateKeySecretRef = {
          name = "letsencrypt-issuer"
        }
        solvers = [
          { http01 = { ingress = { class = "nginx" } } }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

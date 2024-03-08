locals {
  letsencrypt_issuer_email = "cloudflare@islandbitcoin.com"
  ingress_namespace        = "${var.name_prefix}-ingress"
  ingress_service_name     = "${var.name_prefix}-ingress"
  jaeger_host              = "opentelemetry-collector.${local.otel_namespace}.svc.cluster.local"
  enable_tracing           = true
}

resource "kubernetes_secret" "cloudflare_api_key" {
  metadata {
    name      = "cloudflare-api-key-secret"
    namespace = local.ingress_namespace
  }

  data = {
    api-key = var.cloudflare_api_key
  }
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
      jaeger_host    = local.jaeger_host
      service_name   = local.ingress_service_name
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
          { dns01 = {
              cloudflare = {
                email = var.cloudflare_email,
                apiKeySecretRef = {
                  name = kubernetes_secret.cloudflare_api_key.metadata[0].name,
                  key  = "api-key"
                }
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

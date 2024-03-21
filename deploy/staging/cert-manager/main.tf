variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email associated with the Cloudflare account"
  type        = string
  sensitive   = true
}

# locals {
#   chart_dir = "${path.module}/../../../helm/flash-deps" 
# }

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "cloudflare_api_key" {
  metadata {
    name      = "cloudflare-api-key-secret"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    api-key = var.cloudflare_api_key
  }
}

# resource "helm_release" "galoy_deps" {
#   name      = "galoy-deps"
#   chart     = "${path.module}/chart"
#   namespace = kubernetes_namespace.testflight.metadata[0].name

#   values = [
#     templatefile("${path.module}/testflight-values.yml.tmpl", {
#       service_name : local.service_name
#       jaeger_host : local.jaeger_host
#       kubemonkey_fullname_override : local.kubemonkey_fullname_override
#     })
#   ]

#   dependency_update = true
# }
resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  chart     = "jetstack/cert-manager" # local.chart_dir
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  values = [
    # file("${path.module}/cert-manager-values.yml.tmpl")
    file("${path.module}/staging-values.yaml")
  ]
}

# Define Certificate authority. Ref: https://cert-manager.io/docs/concepts/issuer/
resource "kubernetes_manifest" "issuer" {
  # depends_on = [helm_release.cert_manager] # crds must be created before terraform execution plan
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer" # issue Certificates across all namespaces
    metadata = {
      name = "letsencrypt-issuer"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"  
        # server = "https://acme-staging-v02.api.letsencrypt.org/directory" # https://letsencrypt.org/docs/staging-environment/
        email  = var.cloudflare_email # TODO: Look into if this should be a LetsEncrypt email
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
}

# Redundant
provider "kubernetes" {
  config_path    = "~/.kube/config"  # Path to your kubeconfig file
  config_context = "do-nyc1-flashcluster"  # Name of the Kubernetes context to use
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "do-nyc1-flashcluster"  # Name of the Kubernetes context to use
 }
}
variable "namespace" {
  type    = string
  description = "The namespace for the flash app"
  default = "flash"
}

# Defined in secrets.yaml
resource "kubernetes_secret" "ibex_auth" {
  metadata {
    name      = "ibex-auth"
    namespace = var.namespace
  }

  data = {
    "api-password" : var.IBEX_PASSWORD 
    "webhook-secret" : "not-so-secret"
  }
}

# Captcha. Is this a real secret?
resource "kubernetes_secret" "geetest_key" {
  metadata {
    name      = "geetest-key"
    namespace = var.namespace
  }

  data = {
    key = "geetest_key"
    id  = "geetest_id"
  }
}

resource "kubernetes_secret" "mongodb_creds" {
  metadata {
    name      = "galoy-mongodb"
    namespace = var.namespace
  }

  data = {
    "mongodb-password" : "password"
    "mongodb-passwords" : "password"
    "mongodb-root-password" : "password"
    "mongodb-replica-set-key" : "replica"
  }
}

resource "kubernetes_secret" "mongodb_connection_string" {
  metadata {
    name      = "galoy-mongodb-connection-string"
    namespace = var.namespace
  }

  data = {
    "mongodb-con" : "mongodb://testUser:password@flash-mongodb:27017/galoy"
  }
}

resource "kubernetes_secret" "redis_creds" {
  metadata {
    name      = "galoy-redis-pw"
    namespace = var.namespace
  }

  data = {
    "redis-password" : "password"
  }
}

# What's this for?
resource "kubernetes_secret" "dropbox_access_token" {
  metadata {
    name      = "dropbox-access-token"
    namespace = var.namespace
  }

  data = {
    token = "dummy"
  }
}

# What's this for?
resource "kubernetes_secret" "twilio_secret" {
  metadata {
    name      = "twilio-secret"
    namespace = var.namespace
  }

  data = {
    TWILIO_VERIFY_SERVICE_ID = var.TWILIO_VERIFY_SERVICE_ID
    TWILIO_ACCOUNT_SID       = var.TWILIO_ACCOUNT_SID
    TWILIO_AUTH_TOKEN        = var.TWILIO_AUTH_TOKEN
  }
}

# What's this for?
resource "kubernetes_secret" "svix_secret" {
  metadata {
    name      = "svix-secret"
    namespace = var.namespace
  }
  data = {
    "svix-secret" = "dummy"
  }
}

# What's this for?
resource "kubernetes_secret" "proxy_check_api_key" {
  metadata {
    name      = "proxy-check-api-key"
    namespace = var.namespace
  }
  data = {
    "api-key" = "dummy"
  }
}

resource "kubernetes_secret" "price_history_postgres_creds" {
  metadata {
    name      = "galoy-price-history-postgres-creds"
    namespace = var.namespace
  }

  data = {
    username = "price-history"
    password = "price-history"
    database = "price-history"
  }
}

# resource "kubernetes_secret" "smoketest" {
#   metadata {
#     name      = "galoy-smoketest"
#     namespace = var.namespace # local.smoketest_namespace
#   }
#   data = {
#     galoy_endpoint         = local.galoy-oathkeeper-proxy-host
#     galoy_port             = 4455
#     price_history_endpoint = "galoy-price-history.${local.flash_namespace}.svc.cluster.local"
#     price_history_port     = 50052
#   }
# }

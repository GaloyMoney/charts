
locals {
  bitcoin_network     = "flash"
  smoketest_namespace = "flash"
  flash_namespace     = "flash"
  bitcoin_namespace   = "flash"
  bitcoin_secret      = "bitcoind-rpcpassword"

  postgres_database = "price-history"
  postgres_username = "price-history"
  postgres_password = "price-history"

  flash-oathkeeper-proxy-host = "flash-oathkeeper-proxy.${local.flash_namespace}.svc.cluster.local"
  kratos_pg_host              = "postgresql.${local.flash_namespace}.svc.cluster.local" # updated in postgresql update: flash-postgresql.staging-flash.svc.cluster.local
}
# data "kubernetes_secret" "network" {
#   metadata {
#     name      = "network"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "network" {
  metadata {
    name      = "network"
    namespace = var.namespace
  }

  data ={

  } 
}

resource "kubernetes_secret" "bria" {
  metadata {
    name      = "bria-api-key"
    namespace = var.namespace
  }

  data = {
    api-key = "bria_dev_000000000000000000000"
  }
}
resource "kubernetes_secret" "gcs_sa_key" {
  metadata {
    name      = "gcs-sa-key"
    namespace = var.namespace
  }

  data = {}
}
# data "kubernetes_secret" "bitcoin_rpcpassword" {
#   metadata {
#     name      = local.bitcoin_secret
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "bitcoinrpc_password" {
  metadata {
    name      = "bitcoind-rpcpassword"
    namespace = var.namespace
  }

  data = {} # data.kubernetes_secret.bitcoin_rpcpassword.data
}

# data "kubernetes_secret" "lnd2_pubkey" {
#   metadata {
#     name      = "lnd1-pubkey"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "lnd2_pubkey" {
  metadata {
    name      = "lnd2-pubkey"
    namespace = var.namespace
  }

  data = {
    pubkey: "03ca1907342d5d37744cb7038375e1867c24a87564c293157c95b2a9d38dcfb4c2"
  } # data.kubernetes_secret.lnd2_pubkey.data
}

# data "kubernetes_secret" "lnd1_pubkey" {
#   metadata {
#     name      = "lnd1-pubkey"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "lnd1_pubkey" {
  metadata {
    name      = "lnd1-pubkey"
    namespace = var.namespace
  }

  data = {
    pubkey: "03ca1907342d5d37744cb7038375e1867c24a87564c293157c95b2a9d38dcfb4c2",
  }
}

# data "kubernetes_secret" "lnd2_credentials" {
#   metadata {
#     name      = "lnd1-credentials"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "lnd2_credentials" {
  metadata {
    name      = "lnd2-credentials"
    namespace = var.namespace
  }

  data = {
    admin_macaroon_base64: "AgEDbG5kAvgBAwoQB1FdhGa9xoewc1LEXmnURRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYgqHDdwGCqx0aQL1/Z3uUfzCpeBhfapGf9s/AZPOVwf6s=",
    tls_base64: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNZVENDQWdlZ0F3SUJBZ0lSQU9zZzdYWFR4cnVZYlhkeTY2d3RuN1F3Q2dZSUtvWkl6ajBFQXdJd09ERWYKTUIwR0ExVUVDaE1XYkc1a0lHRjFkRzluWlc1bGNtRjBaV1FnWTJWeWRERVZNQk1HQTFVRUF4TU1PRFl4T1RneApNak5tT0Roak1CNFhEVEl6TURFeE9USXdOREUxTTFvWERUTTBNRGN5TVRJd05ERTFNMW93T0RFZk1CMEdBMVVFCkNoTVdiRzVrSUdGMWRHOW5aVzVsY21GMFpXUWdZMlZ5ZERFVk1CTUdBMVVFQXhNTU9EWXhPVGd4TWpObU9EaGoKTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFM1lieUlKWU1Vcm8zZkl0UFFucysxZ2lpTXI5NQpJUXRmclFDQ2JhOWVtcjI4TENmbk1vYy9VQVFwUlg3QVlvVFRneUdiMFBuZGNUODF5ZVgvYTlPa0RLT0I4VENCCjdqQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0V3WURWUjBsQkF3d0NnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC8KQkFVd0F3RUIvekFkQmdOVkhRNEVGZ1FVL1AxRHpJUkRzTEhHMU10d3NrZE5nZ0lub1Mwd2daWUdBMVVkRVFTQgpqakNCaTRJTU9EWXhPVGd4TWpObU9EaGpnZ2xzYjJOaGJHaHZjM1NDRFd4dVpDMXZkWFJ6YVdSbExUR0NEV3h1ClpDMXZkWFJ6YVdSbExUS0NEV3h1WkMxdmRYUnphV1JsTFRPQ0JHeHVaREdDQkd4dVpES0NCSFZ1YVhpQ0NuVnUKYVhod1lXTnJaWFNDQjJKMVptTnZibTZIQkg4QUFBR0hFQUFBQUFBQUFBQUFBQUFBQUFBQUFBR0hCS3dUQUJBdwpDZ1lJS29aSXpqMEVBd0lEU0FBd1JRSWhBSU5DNlJWQ3d6SzFYRnFxeVNLY0Y4QzQ5ZFlSOThjemdLNVdkcmNOCkxYYWlBaUJHYmtWeGhaeHdDaDVLQ1o1Z2M1Q2FsQ0RvaGNxVkdiaHNya0hHTFhpdHN3PT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
  } # data.kubernetes_secret.lnd2_credentials.data
}

# data "kubernetes_secret" "loop2_credentials" {
#   metadata {
#     name      = "loop1-credentials"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "loop2_credentials" {
  metadata {
    name      = "loop2-credentials"
    namespace = var.namespace
  }

  data = {
    loop_macaroon_base64: "AgEDbG5kAvgBAwoQB1FdhGa9xoewc1LEXmnURRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYgqHDdwGCqx0aQL1/Z3uUfzCpeBhfapGf9s/AZPOVwf6s=",
    tls_base64: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNZVENDQWdlZ0F3SUJBZ0lSQU9zZzdYWFR4cnVZYlhkeTY2d3RuN1F3Q2dZSUtvWkl6ajBFQXdJd09ERWYKTUIwR0ExVUVDaE1XYkc1a0lHRjFkRzluWlc1bGNtRjBaV1FnWTJWeWRERVZNQk1HQTFVRUF4TU1PRFl4T1RneApNak5tT0Roak1CNFhEVEl6TURFeE9USXdOREUxTTFvWERUTTBNRGN5TVRJd05ERTFNMW93T0RFZk1CMEdBMVVFCkNoTVdiRzVrSUdGMWRHOW5aVzVsY21GMFpXUWdZMlZ5ZERFVk1CTUdBMVVFQXhNTU9EWXhPVGd4TWpObU9EaGoKTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFM1lieUlKWU1Vcm8zZkl0UFFucysxZ2lpTXI5NQpJUXRmclFDQ2JhOWVtcjI4TENmbk1vYy9VQVFwUlg3QVlvVFRneUdiMFBuZGNUODF5ZVgvYTlPa0RLT0I4VENCCjdqQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0V3WURWUjBsQkF3d0NnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC8KQkFVd0F3RUIvekFkQmdOVkhRNEVGZ1FVL1AxRHpJUkRzTEhHMU10d3NrZE5nZ0lub1Mwd2daWUdBMVVkRVFTQgpqakNCaTRJTU9EWXhPVGd4TWpObU9EaGpnZ2xzYjJOaGJHaHZjM1NDRFd4dVpDMXZkWFJ6YVdSbExUR0NEV3h1ClpDMXZkWFJ6YVdSbExUS0NEV3h1WkMxdmRYUnphV1JsTFRPQ0JHeHVaREdDQkd4dVpES0NCSFZ1YVhpQ0NuVnUKYVhod1lXTnJaWFNDQjJKMVptTnZibTZIQkg4QUFBR0hFQUFBQUFBQUFBQUFBQUFBQUFBQUFBR0hCS3dUQUJBdwpDZ1lJS29aSXpqMEVBd0lEU0FBd1JRSWhBSU5DNlJWQ3d6SzFYRnFxeVNLY0Y4QzQ5ZFlSOThjemdLNVdkcmNOCkxYYWlBaUJHYmtWeGhaeHdDaDVLQ1o1Z2M1Q2FsQ0RvaGNxVkdiaHNya0hHTFhpdHN3PT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
  } # data.kubernetes_secret.loop2_credentials.data
}

# data "kubernetes_secret" "lnd1_credentials" {
#   metadata {
#     name      = "lnd1-credentials"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "lnd1_credentials" {
  metadata {
    name      = "lnd1-credentials"
    namespace = var.namespace
  }

  data = {
    admin_macaroon_base64: "AgEDbG5kAvgBAwoQB1FdhGa9xoewc1LEXmnURRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYgqHDdwGCqx0aQL1/Z3uUfzCpeBhfapGf9s/AZPOVwf6s=",
    tls_base64: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNZVENDQWdlZ0F3SUJBZ0lSQU9zZzdYWFR4cnVZYlhkeTY2d3RuN1F3Q2dZSUtvWkl6ajBFQXdJd09ERWYKTUIwR0ExVUVDaE1XYkc1a0lHRjFkRzluWlc1bGNtRjBaV1FnWTJWeWRERVZNQk1HQTFVRUF4TU1PRFl4T1RneApNak5tT0Roak1CNFhEVEl6TURFeE9USXdOREUxTTFvWERUTTBNRGN5TVRJd05ERTFNMW93T0RFZk1CMEdBMVVFCkNoTVdiRzVrSUdGMWRHOW5aVzVsY21GMFpXUWdZMlZ5ZERFVk1CTUdBMVVFQXhNTU9EWXhPVGd4TWpObU9EaGoKTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFM1lieUlKWU1Vcm8zZkl0UFFucysxZ2lpTXI5NQpJUXRmclFDQ2JhOWVtcjI4TENmbk1vYy9VQVFwUlg3QVlvVFRneUdiMFBuZGNUODF5ZVgvYTlPa0RLT0I4VENCCjdqQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0V3WURWUjBsQkF3d0NnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC8KQkFVd0F3RUIvekFkQmdOVkhRNEVGZ1FVL1AxRHpJUkRzTEhHMU10d3NrZE5nZ0lub1Mwd2daWUdBMVVkRVFTQgpqakNCaTRJTU9EWXhPVGd4TWpObU9EaGpnZ2xzYjJOaGJHaHZjM1NDRFd4dVpDMXZkWFJ6YVdSbExUR0NEV3h1ClpDMXZkWFJ6YVdSbExUS0NEV3h1WkMxdmRYUnphV1JsTFRPQ0JHeHVaREdDQkd4dVpES0NCSFZ1YVhpQ0NuVnUKYVhod1lXTnJaWFNDQjJKMVptTnZibTZIQkg4QUFBR0hFQUFBQUFBQUFBQUFBQUFBQUFBQUFBR0hCS3dUQUJBdwpDZ1lJS29aSXpqMEVBd0lEU0FBd1JRSWhBSU5DNlJWQ3d6SzFYRnFxeVNLY0Y4QzQ5ZFlSOThjemdLNVdkcmNOCkxYYWlBaUJHYmtWeGhaeHdDaDVLQ1o1Z2M1Q2FsQ0RvaGNxVkdiaHNya0hHTFhpdHN3PT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
  } # data.kubernetes_secret.lnd1_credentials.data
}

# data "kubernetes_secret" "loop1_credentials" {
#   metadata {
#     name      = "loop1-credentials"
#     namespace = local.bitcoin_namespace
#   }
# }

resource "kubernetes_secret" "loop1_credentials" {
  metadata {
    name      = "loop1-credentials"
    namespace = var.namespace
  }

  data = {
    loop_macaroon_base64: "AgEDbG5kAvgBAwoQB1FdhGa9xoewc1LEXmnURRIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYgqHDdwGCqx0aQL1/Z3uUfzCpeBhfapGf9s/AZPOVwf6s=",
    tls_base64: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNZVENDQWdlZ0F3SUJBZ0lSQU9zZzdYWFR4cnVZYlhkeTY2d3RuN1F3Q2dZSUtvWkl6ajBFQXdJd09ERWYKTUIwR0ExVUVDaE1XYkc1a0lHRjFkRzluWlc1bGNtRjBaV1FnWTJWeWRERVZNQk1HQTFVRUF4TU1PRFl4T1RneApNak5tT0Roak1CNFhEVEl6TURFeE9USXdOREUxTTFvWERUTTBNRGN5TVRJd05ERTFNMW93T0RFZk1CMEdBMVVFCkNoTVdiRzVrSUdGMWRHOW5aVzVsY21GMFpXUWdZMlZ5ZERFVk1CTUdBMVVFQXhNTU9EWXhPVGd4TWpObU9EaGoKTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFM1lieUlKWU1Vcm8zZkl0UFFucysxZ2lpTXI5NQpJUXRmclFDQ2JhOWVtcjI4TENmbk1vYy9VQVFwUlg3QVlvVFRneUdiMFBuZGNUODF5ZVgvYTlPa0RLT0I4VENCCjdqQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0V3WURWUjBsQkF3d0NnWUlLd1lCQlFVSEF3RXdEd1lEVlIwVEFRSC8KQkFVd0F3RUIvekFkQmdOVkhRNEVGZ1FVL1AxRHpJUkRzTEhHMU10d3NrZE5nZ0lub1Mwd2daWUdBMVVkRVFTQgpqakNCaTRJTU9EWXhPVGd4TWpObU9EaGpnZ2xzYjJOaGJHaHZjM1NDRFd4dVpDMXZkWFJ6YVdSbExUR0NEV3h1ClpDMXZkWFJ6YVdSbExUS0NEV3h1WkMxdmRYUnphV1JsTFRPQ0JHeHVaREdDQkd4dVpES0NCSFZ1YVhpQ0NuVnUKYVhod1lXTnJaWFNDQjJKMVptTnZibTZIQkg4QUFBR0hFQUFBQUFBQUFBQUFBQUFBQUFBQUFBR0hCS3dUQUJBdwpDZ1lJS29aSXpqMEVBd0lEU0FBd1JRSWhBSU5DNlJWQ3d6SzFYRnFxeVNLY0Y4QzQ5ZFlSOThjemdLNVdkcmNOCkxYYWlBaUJHYmtWeGhaeHdDaDVLQ1o1Z2M1Q2FsQ0RvaGNxVkdiaHNya0hHTFhpdHN3PT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
  } # data.kubernetes_secret.loop1_credentials.data
}

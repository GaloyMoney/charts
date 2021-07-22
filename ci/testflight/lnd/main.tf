resource "null_resource" "dummy" {
}

terraform {
  backend "gcs" {
    bucket = "galoy-staging-tf-state"
    prefix = "galoy-staging/services/lnd-testflight"
  }
}

#!/bin/bash

set -eu

source smoketest-settings/helpers.sh

export BRIA_ADMIN_API_KEY=`setting "bria_admin_api_key"`
export BRIA_ADMIN_API_URL=`setting "bria_admin_api_endpoint"`
export BRIA_API_URL=`setting "bria_api_endpoint"`

mkdir -p bria-test
pushd bria-test

cat <<EOF > main.tf
terraform {
  required_providers {
    briaadmin = {
      source  = "galoymoney/briaadmin"
      version = "0.0.4"
    }
    bria = {
      source  = "galoymoney/bria"
      version = "0.0.2"
    }
  }
}
resource "random_string" "postfix" {
  length  = 6
  special = false
  upper   = false
  numeric  = false
}
resource "briaadmin_account" "example" {
  name = "tf-example-\${random_string.postfix.result}"
}
provider "bria" {
  api_key = briaadmin_account.example.api_key
}
resource "bria_xpub" "lnd" {
  name       = "lnd"
  xpub       = "tpubDDEGUyCLufbxAfQruPHkhUcu55UdhXy7otfcEQG4wqYNnMfq9DbHPxWCqpEQQAJUDi8Bq45DjcukdDAXasKJ2G27iLsvpdoEL5nTRy5TJ2B"
  derivation = "m/64h/1h/0"
}
resource "bria_wallet" "example" {
  name  = "example"
  xpubs = [bria_xpub.lnd.id]
}
EOF

terraform init
terraform apply -auto-approve

popd

rm -rf bria-test

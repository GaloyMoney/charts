terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# provider "cloudflare" {
#   email = var.cloudflare_email
#   api_key = var.cloudflare_api_key
# }

variable "cloudflare_api_token" {
  description = "Token for interacting with Cloudflare account"
  type        = string
  sensitive   = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# data "cloudflare_api_token_permission_groups" "all" {}

# output "permissions" {
#   value = data.cloudflare_api_token_permission_groups.all
# }

### GET dns zones
# data "cloudflare_zones" "staging" {
#   filter {
#     name = "api.staging.flashapp.me"
#     lookup_type = "contains"
#   }
# }
# # staging_zones contains id and name fields
# output "staging_zones" {
#   value = data.cloudflare_zones.staging.zones
# }

# data "cloudflare_zone" "staging" {
#   zone_id = "e7454b5ba25146abe8f61821528d0a23"
# }

# output "staging_zones" {
#   value = data.cloudflare_zone.staging.name
# }

# Set Cloudflare DNS record
resource "cloudflare_record" "set" {
  zone_id = "e7454b5ba25146abe8f61821528d0a23" # data.cloudflare_zones.staging.id # "d41d8cd98f00b204e9800998ecf8427e" # get from data.cloudflare_zones
  name    = "*.staging.flashapp.me"
  value   = "161.35.254.122"
  type    = "A"
  ttl     = 3600
  allow_overwrite = true
}

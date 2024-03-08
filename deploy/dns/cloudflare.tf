terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

### GET dns zones
# data "cloudflare_zones" "staging" {
#   filter {
#     name = "staging.flashapp.me"
#   }
# }

# staging_zones contains id and name fields
# output "staging_zones" {
#   value = data.cloudflare_zones.staging.*.id
# }

# Set Cloudflare DNS record
resource "cloudflare_record" "set" {
  zone_id = "d41d8cd98f00b204e9800998ecf8427e" # get from data.cloudflare_zones
  name    = "*.staging.flashapp.me"
  value   = "157.230.202.83"
  type    = "A"
  ttl     = 3600
  allow_overwrite = true
}

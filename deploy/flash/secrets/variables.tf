variable "TWILIO_VERIFY_SERVICE_ID" {
  description = "The ID for the Twilio Verify Service"
  type        = string
  sensitive   = true
}

variable "TWILIO_ACCOUNT_SID" {
  description = "The Account SID for Twilio"
  type        = string
  sensitive   = true
}

variable "TWILIO_AUTH_TOKEN" {
  description = "The Auth Token for Twilio"
  type        = string
  sensitive   = true
}

variable "IBEX_PASSWORD" {
  description = "The api password to ibex"
  type        = string
  sensitive   = true
}


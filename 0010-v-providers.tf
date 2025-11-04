##########################
# Providers
##########################

variable "tenant_id" {
  description = "ID of tenant where this spoke reside in."
  type        = string
}

variable "subscription_id" {
  description = "ID of subscription where this spoke reside in."
  type        = string
}

variable "client_id" {
  description = "ID of service principal used for provisioning resources in this spoke."
  type        = string
  default     = null
}

variable "client_secret" {
  description = "Password of service principal used for provisioning resources in this spoke."
  type        = string
  default     = null
}

variable "use_oidc" {
  description = "Specify whether to use OIDC."
  type        = bool
  default     = false
}

variable "oidc_request_token" {
  description = "Client ID of the service principal"
  type        = string
  default     = null
}

variable "oidc_request_url" {
  description = "Client ID of the service principal"
  type        = string
  default     = null
}
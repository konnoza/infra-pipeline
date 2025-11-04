variable "keyvault_sku" {
  description = "The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`."
  type        = string
  default     = "standard"
}

variable "keyvault_purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false
}

variable "keyvault_access_policies" {
  description = "Access policies for Key Vault."
  type        = list(any)
  default     = []
}

variable "keyvault_contact_email" {
  description = "Email contact for Key Vault."
  type        = string
  default     = null
}

variable "keyvault_contact_fullname" {
  description = "Fullname contact for Key Vault."
  type        = string
  default     = null
}

variable "id_iac_principal_id" {
  type    = string
  default = null
}

variable "id_aks_principal_id" {
  type    = string
  default = null
}

variable "contact_email" {
  description = "Email of certificate contact"
  type        = string
  default     = ""
}

variable "contact_fullname" {
  description = "Fullname of certificate contact"
  type        = string
  default     = ""
}
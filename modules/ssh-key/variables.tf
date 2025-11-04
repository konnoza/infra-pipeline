variable "public_ssh_key" {
  description = "An ssh key set in the main module."
  type        = string
  default     = ""
}

variable "hostname" {
  description = "The hostname of virtual machine to be deployed."
  type        = string
  default     = ""
}

variable "key_vault_storage_enabled" {
  description = "Specify whether to store private ssh key to key vault. if `true`, `key_vault_id` must be supplied."
  type        = bool
  default     = false
}

variable "key_vault_id" {
  description = "ID of key vault to store ssh key."
  type        = string
  default     = ""
}
# ----- Key Vault -----
variable "name" {
  description = "Specifies the name of the Key Vault. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default = {
    "managedBy" = "Terraform"
    "warning"   = "Please specify the proper tags"
  }
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "southeastasia"
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = can(regex("^(standard|premium)$", var.sku_name))
    error_message = "The sku_name value can be ==> SystemAssigned, UserAssigned."
  }
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted (7-90)."
  type        = string
  default     = null

  validation {
    condition     = var.soft_delete_retention_days == null || (coalesce(var.soft_delete_retention_days, 7) >= 7 && coalesce(var.soft_delete_retention_days, 7) <= 90)
    error_message = "The soft_delete_retention_days value can be ==> 7-90."
  }
}

variable "purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = false
}

variable "enable_network_acls" {
  description = "Allow trusted Microsoft services to bypass this firewall? (not Access policies)"
  type        = bool
  default     = false
}

variable "network_acls_allow_trusted_microsoft_services" {
  description = "Allow trusted Microsoft services to bypass this firewall? (not Access policies)"
  type        = bool
  default     = true
}

variable "network_acls_default_action" {
  description = "The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids"
  type        = string
  default     = "Deny"

  validation {
    condition     = can(regex("^(Allow|Deny)$", var.network_acls_default_action))
    error_message = "The network_acls_default_action value can be ==> Allow, Deny."
  }
}

variable "network_acls_allow_my_current_ip" {
  description = "Add my current public ip address in `network_acls_ip_rules`."
  type        = bool
  default     = false
}

variable "network_acls_ip_rules" {
  description = "CIDR block to be allowed accessing in case you select connectivity_method = selected_network"
  type        = list(string)
  default     = []
}

variable "network_acls_virtual_network_subnet_ids" {
  description = "Subnet ID's to be allowed accessing in case you select connectivity_method = selected_network or private_endpoint"
  type        = list(string)
  default     = []
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

variable "contacts" {
  description = <<EOF
A list of certificate contact.
```
list(object{
  email = string # (Require) E-mail address of the contact.
  name  = string # Name of the contact.
  phone = string # Phone number of the contact.
})
```
EOF
  type        = list(any)
  default     = []
}

variable "access_policies" {
  description = <<EOF
List of Object ID of user and access permission (up to 1024 objects):
```
list(object{
  object_id               = string
  certificate_permissions = list(string)
  key_permissions         = list(string)
  secret_permissions      = list(string)
  storage_permissions     = list(string)
})
```
EOF
  type        = list(any)
  default     = []
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this Key Vault."
  type        = bool
  default     = true
}

# ----- Private Endpoint -----

variable "enable_private_endpoint" {
  description = "Enable private endpoint to the storage ?"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "ID of private DNS zone to register private link."
  type        = string
  default     = null
}

variable "link_snet_id" {
  description = "ID of subnet where private endpoint will be created."
  type        = string
  default     = null
}

variable "pe_name" {
  description = "Name of private endpoint"
  type        = string
  default     = ""
}

# ----- Diagnostic ------

variable "diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  log                            = list(string) # ["AuditEvent", "AzurePolicyEvaluationDetails",]
  enabled_categories             = list(string) # ["audit", "allLogs",]
  metric                         = list(string) # ["AllMetrics",]
  log                            = list(string) # Same as `enabled_logs` but log will be deprecated in AzureRM 4.0
  storage_account_id             = string 
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "Dedicated" or null
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
  partner_solution_id            = string
},
```
EOT
  type        = list(any)
  default     = []
}
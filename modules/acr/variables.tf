variable "name" {
  description = "Name of the contianer registry"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name to store this container registry"
  type        = string
}

variable "location" {
  description = "Region that this container registry will be created"
  type        = string
  default     = "southeastasia"
}

variable "sku" {
  description = "Type of this container registry"
  type        = string
  default     = "Standard"

  validation {
    condition     = can(regex("^(Basic|Standard|Premium)$", var.sku))
    error_message = "The sku value can be ==> Basic, Standard, Premium (private endpoint)."
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry."
  type        = bool
  default     = false
}

variable "anonymous_pull_enabled" {
  description = "Whether allows anonymous (unauthenticated) pull access to this Container Registry? This is only supported on resources with the `Standard` or `Premium` SKU."
  type        = bool
  default     = false
}

variable "network_rule_bypass_option" {
  description = "Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are `None` and `AzureServices`."
  type        = string
  default     = "AzureServices"
}

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Container Registry. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry."
  type        = list(string)
  default     = []
}

variable "encryption_enabled" {
  description = "Boolean value that indicates whether encryption is enabled."
  type        = bool
  default     = false
}

variable "encryption_key_vault_key_id" {
  description = "The ID of the Key Vault Key."
  type        = string
  default     = null
}

variable "encryption_identity_client_id" {
  description = "The client ID of the managed identity associated with the encryption key."
  type        = string
  default     = null
}

variable "georeplications" {
  description = <<EOT
The configuration of geo-replicated ontainer registry:
```
georeplications = [
  {
    location                  = string # A location where the container registry should be geo-replicated.
    regional_endpoint_enabled = bool   # Whether regional endpoint is enabled for this Container Registry?
    zone_redundancy_enabled   = bool   # Whether zone redundancy is enabled for this replication location?
  },
]
```
EOT
  type        = list(any)
  default     = []
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "Boolean value that indicates whether export policy is enabled. In order to set it to false, make sure the public_network_access_enabled is also set to false."
  type        = bool
  default     = true
}

variable "data_endpoint_enabled" {
  description = "Whether to enable dedicated data endpoints for this Container Registry? This is only supported on resources with the Premium SKU."
  type        = bool
  default     = false
}

variable "quarantine_policy_enabled" {
  description = "Boolean value that indicates whether quarantine policy is enabled."
  type        = bool
  default     = false
}

variable "network_rule_set" {
  description = <<EOT
The network rule set configuration:
```
network_rule_set = {
  default_action = string # The behaviour for requests matching no rules. Either `Allow` or `Deny`. Defaults to `Allow`
  ip_rules         = [
    {
      action   = "Allow" # The behaviour for requests matching this rule. 
      ip_range = string  # The CIDR block from which requests will match the rule.
    },
  ]
}
```
EOT
  type = object({
    default_action = string
    ip_rules       = list(any)
  })
  default = {
    default_action = "Allow"
    ip_rules       = []
  }
}

variable "retention_policy_enabled" {
  description = "Boolean value that indicates whether the policy is enabled."
  type        = bool
  default     = false
}

variable "retention_policy_in_days" {
  description = "Number of days for the retention policy."
  type        = number
  default     = 7 // Set a default value if appropriate

  validation {
    condition     = var.retention_policy_in_days > 0
    error_message = "The retention policy must be a positive number of days."
  }
}

variable "trust_policy_enabled" {
  description = "Boolean value that indicates whether the policy is enabled."
  type        = bool
  default     = false
}

#
# Private Link
#

variable "enable_private_endpoint" {
  description = "Enable Private Endpoint"
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

#
# Diagnostic Log
#

variable "diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  enabled_logs                   = list(string) # ["ContainerRegistryLoginEvents", "ContainerRegistryRepositoryEvents", ]
  enabled_categories             = list(string) # ["audit", "allLogs"]
  metric                         = list(string) # ["AllMetrics",]
  log                            = list(string) # Same as `enabled_logs` but log will be deprecated in AzureRM 4.0
  storage_account_id             = string
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "AzureDiagnostics" or "Dedicated"
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
},
```
EOT
  type        = list(any)
  default     = []
}
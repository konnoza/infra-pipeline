variable "name" {
  description = "Specifies the name of the storage account. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Microsoft SQL Server."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "southeastasia"
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"

  validation {
    condition     = can(regex("^(Standard|Premium)$", var.account_tier))
    error_message = "The valid value are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
  default     = "LRS"

  validation {
    condition     = can(regex("^(LRS|GRS|RAGRS|ZRS|GZRS|RAGZRS)$", var.account_replication_type))
    error_message = "The valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  }
}

variable "account_kind" {
  description = "Defines the Kind of account."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = can(regex("^(BlobStorage|BlockBlobStorage|FileStorage|Storage|StorageV2)$", var.account_kind))
    error_message = "The valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  }
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts."
  type        = string
  default     = "Hot"

  validation {
    condition     = can(regex("^(Hot|Cool)$", var.access_tier))
    error_message = "The valid options are Hot and Cool."
  }
}

variable "enable_https_traffic_only" {
  description = "Boolean flag which forces HTTPS if enabled, see here for more information."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = can(regex("^(TLS1_0|TLS1_1|TLS1_2)$", var.min_tls_version))
    error_message = "The valid options are TLS1_0, TLS1_1, and TLS1_2."
  }
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled?"
  type        = bool
  default     = false
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created."
  type        = string
  default     = null
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD)."
  type        = bool
  default     = true
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "queue_encryption_key_type" {
  description = "The encryption type of the queue service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "table_encryption_key_type" {
  description = "he encryption type of the table service. Possible values are `Service` and `Account`. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Is Large File Share Enabled?"
  type        = bool
  default     = false
}

variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account."
  type        = bool
  default     = false
}

variable "routing_publish_internet_endpoints" {
  description = "Should internet routing storage endpoints be published?"
  type        = bool
  default     = null
}

variable "routing_publish_microsoft_endpoints" {
  description = "Should Microsoft routing storage endpoints be published?"
  type        = bool
  default     = null
}

variable "routing_choice" {
  description = " Specifies the kind of network routing opted by the user. Possible values are `InternetRouting` and `MicrosoftRouting`."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = null
}

variable "static_website_enabled" {
  description = "Specify whether to enable static website `$web` on the storage account?"
  type        = bool
  default     = false
}

variable "static_website_index_document" {
  description = "The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive."
  type        = string
  default     = null
}

variable "static_website_error_404_document" {
  description = "The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file."
  type        = string
  default     = null
}

variable "custom_domain_name" {
  description = "The Custom Domain Name to use for the Storage Account, which will be validated by Azure."
  type        = string
  default     = null
}

variable "custom_domain_use_subdomain" {
  description = "Should the Custom Domain Name be validated by using indirect CNAME validation?"
  type        = bool
  default     = false
}

variable "blob_properties_cors_rules" {
  description = <<EOT
A list of Resource sharing (CORS) rules for all blob in this storage account:
```
blob_properties_cors_rules = {
  allowed_headers    = list(string) (required)
  allowed_methods    = list(string) (required) # [ "DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH" ]
  allowed_origins    = list(string) (required)
  exposed_headers    = list(string) (required)
  max_age_in_seconds = number       (required)
}
```
EOT
  type        = list(any)
  default     = []
}

variable "blob_properties_delete_retention_policy_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days."
  type        = number
  default     = 7
}

variable "blob_properties_container_delete_retention_policy_days" {
  description = "Specifies the number of days that the container should be retained, between `1` and `365` days."
  type        = number
  default     = 7
}

variable "blob_properties_versioning_enabled" {
  description = "Is versioning enabled?"
  type        = bool
  default     = false
}

variable "blob_properties_change_feed_enabled" {
  description = "Is the blob service properties for change feed events enabled?"
  type        = bool
  default     = false
}
variable "blob_properties_change_feed_retention_in_days" {
  description = "The duration of change feed events retention in days. The possible values are between `1` and `146000` days (400 years). Setting this to null (or omit this in the configuration file) indicates an infinite retention of the change feed."
  type        = number
  default     = null
}

variable "blob_properties_default_service_version" {
  description = "The API Version which should be used by default for requests to the Data Plane API if an incoming request doesn't specify an API Version."
  type        = string
  default     = null
}

variable "blob_properties_last_access_time_enabled" {
  description = "Is the last access time based tracking enabled?"
  type        = bool
  default     = false
}

variable "blob_properties_restore_policy_enabled" {
  description = "Specify whether restore policy is enabled?"
  type        = bool
  default     = false
}

variable "blob_properties_restore_policy_days" {
  description = "Specifies the number of days that the blob can be restored, between `1` and `365` days. This must be less than the days specified for `delete_retention_policy`."
  type        = number
  default     = null
}

variable "queue_properties_cors_rules" {
  description = <<EOT
A list of Resource sharing (CORS) rules for all blob in this storage account:
```
queue_properties_cors_rules = {
  allowed_headers    = list(string) (required)
  allowed_methods    = list(string) (required) # [ "DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH" ]
  allowed_origins    = list(string) (required)
  exposed_headers    = list(string) (required)
  max_age_in_seconds = number       (required)
}
```
EOT
  type        = list(any)
  default     = []
}

variable "queue_properties_logging_delete" {
  description = "Indicates whether all delete requests should be logged. Changing this forces a new resource."
  type        = bool
  default     = false
}

variable "queue_properties_logging_read" {
  description = "Indicates whether all read requests should be logged. Changing this forces a new resource."
  type        = bool
  default     = false
}

variable "queue_properties_logging_version" {
  description = "The version of storage analytics to configure. Changing this forces a new resource."
  type        = string
  default     = "1.0"
}

variable "queue_properties_logging_write" {
  description = "Indicates whether all write requests should be logged. Changing this forces a new resource."
  type        = bool
  default     = false
}

variable "queue_properties_logging_retention_policy_days" {
  description = "Specifies the number of days that logs will be retained. Changing this forces a new resource."
  type        = number
  default     = null
}

variable "queue_properties_minute_metrics_enabled" {
  description = "Indicates whether minute metrics are enabled for the Queue service. Changing this forces a new resource."
  type        = bool
  default     = false
}

variable "queue_properties_minute_metrics_version" {
  description = "The version of storage analytics to configure. Changing this forces a new resource."
  type        = string
  default     = "1.0"
}

variable "queue_properties_minute_metrics_include_apis" {
  description = "Indicates whether metrics should generate summary statistics for called API operations."
  type        = bool
  default     = false
}

variable "queue_properties_minute_metrics_retention_policy_days" {
  description = "Specifies the number of days that logs will be retained. Changing this forces a new resource."
  type        = number
  default     = null
}

variable "queue_properties_hour_metrics_enabled" {
  description = "Indicates whether hour metrics are enabled for the Queue service. Changing this forces a new resource."
  type        = bool
  default     = false
}

variable "queue_properties_hour_metrics_version" {
  description = "The version of storage analytics to configure. Changing this forces a new resource."
  type        = string
  default     = null
}

variable "queue_properties_hour_metrics_include_apis" {
  description = "Indicates whether metrics should generate summary statistics for called API operations."
  type        = bool
  default     = false
}

variable "queue_properties_hour_metrics_retention_policy_days" {
  description = "Specifies the number of days that logs will be retained. Changing this forces a new resource."
  type        = number
  default     = null
}

variable "share_properties_cors_rules" {
  description = <<EOT
A list of Resource sharing (CORS) rules for all blob in this storage account:
```
share_properties_cors_rules = {
  allowed_headers    = list(string) (required)
  allowed_methods    = list(string) (required) # [ "DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH" ]
  allowed_origins    = list(string) (required)
  exposed_headers    = list(string) (required)
  max_age_in_seconds = number       (required)
}
```
EOT
  type        = list(any)
  default     = []
}

variable "share_properties_retention_policy_days" {
  description = "Specifies the number of days that the azurerm_storage_share should be retained, between `1` and `365` days."
  type        = number
  default     = 7
}

variable "share_properties_smb_versions" {
  description = "A set of SMB protocol versions. Possible values are `SMB2.1`, `SMB3.0`, and `SMB3.1.1`."
  type        = list(string)
  default     = []
}

variable "share_properties_smb_authentication_types" {
  description = "A set of SMB authentication methods. Possible values are `NTLMv2`, and `Kerberos`."
  type        = list(string)
  default     = []
}

variable "share_properties_smb_kerberos_ticket_encryption_type" {
  description = " A set of Kerberos ticket encryption. Possible values are `RC4-HMAC`, and `AES-256`."
  type        = list(string)
  default     = []
}

variable "share_properties_smb_channel_encryption_type" {
  description = "A set of SMB channel encryption. Possible values are `AES-128-CCM`, `AES-128-GCM`, and `AES-256-GCM`."
  type        = list(string)
  default     = []
}

variable "share_properties_smb_multichannel_enabled" {
  description = "Indicates whether multichannel is enabled. This is only supported on Premium storage accounts."
  type        = bool
  default     = false
}

variable "azure_files_authentication_enabled" {
  description = "Specify whether to enable authentication for Azure file shares."
  type        = bool
  default     = false
}

variable "azure_files_authentication_directory_type" {
  description = "Specifies the directory service used. Possible values are `AADDS`, `AD` and `AADKERB`."
  type        = string
  default     = "AADDS"
}

variable "azure_files_authentication_ad_storage_sid" {
  description = "Specifies the security identifier (SID) for Azure Storage."
  type        = string
  default     = null
}

variable "azure_files_authentication_ad_domain_name" {
  description = "Specifies the primary domain that the AD DNS server is authoritative for."
  type        = string
  default     = null
}

variable "azure_files_authentication_ad_domain_sid" {
  description = "Specifies the security identifier (SID)."
  type        = string
  default     = null
}

variable "azure_files_authentication_ad_domain_guid" {
  description = "Specifies the domain GUID."
  type        = string
  default     = null
}

variable "azure_files_authentication_ad_forest_name" {
  description = "Specifies the Active Directory forest."
  type        = string
  default     = null
}

variable "azure_files_authentication_ad_netbios_domain_name" {
  description = "Specifies the NetBIOS domain name."
  type        = string
  default     = null
}

variable "immutability_policy_enabled" {
  description = "Specify whether account-level immutability policy is enabled?"
  type        = bool
  default     = false
}

variable "immutability_policy_allow_protected_append_writes" {
  description = "When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted."
  type        = bool
  default     = false
}

variable "immutability_policy_state" {
  description = "Defines the mode of the policy. `Disabled` state disables the policy, `Unlocked` state allows increase and decrease of immutability retention time and also allows toggling allowProtectedAppendWrites property, `Locked` state only allows the increase of the immutability retention time. A policy can only be created in a `Disabled` or `Unlocked` state and can be toggled between the two states. Only a policy in an `Unlocked` state can transition to a `Locked` state which cannot be reverted."
  type        = string
  default     = null
}

variable "immutability_policy_period_since_creation_in_days" {
  description = "The immutability period for the blobs in the container since the policy creation, in days."
  type        = number
  default     = null
}

variable "sas_policy_enabled" {
  description = "Specify whether SAS policy is enabled?"
  type        = bool
  default     = false
}

variable "sas_policy_expiration_period" {
  description = "The SAS expiration period in format of `DD.HH:MM:SS`."
  type        = string
  default     = null
}

variable "sas_policy_expiration_action" {
  description = "The SAS expiration action. The only possible value is `Log` at this moment."
  type        = string
  default     = "Log"
}

variable "sftp_enabled" {
  description = "Specify whether SFTP for the storage account is enabled ? (require `is_hns_enabled` set to `true`)"
  type        = bool
  default     = false
}

variable "allowed_copy_scope" {
  description = "Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are `AAD` and `PrivateLink`."
  type        = string
  default     = null
}

variable "cross_tenant_replication_enabled" {
  description = "Should cross Tenant replication be enabled ?"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled ?"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

#
# Azure File Shares
#

variable "shares" {
  description = <<EOT
A list of file share and quota:
```
shares = [
  {
    name             = string      (required)
    quota_in_gb      = number      (required)
    access_tier      = string      (optional) # Hot, Cool, TransactionOptimized, and Premium
    enabled_protocol = string      (optional) # NFS (access_tier=Premium), and SMB
    metadata         = map(string) (optional)
    acls             = [
      {
        id           = string # e.g. "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"
        permissions  = string # e.g. "rwdl"
        start        = string # e.g. "2019-07-02T09:38:21.0000000Z"
        expiry       = string # e.g. "2019-07-02T10:38:21.0000000Z"
      },
    ]
  },
]
```
EOT
  type        = list(any)
  default     = []
}

#
# Azure Blobs
#

variable "blobs" {
  description = <<EOT
A list of blob, access type and metadata:
```
blobs = [
  { 
    name                  = string      (required)
    container_access_type = string      (optional) # default = private | blob, container or private
    metadata              = map(string) (optional)
  },
]
```
EOT
  type        = list(any)
  default     = []
}

#
# Azure Queues
#

variable "queues" {
  description = <<EOT
A list of queue and metadata:
```
queues = [
  {
    name     = string      (required)
    metadata = map(string) (optional)
  },
]
```
EOT
  type        = list(any)
  default     = []
}

#
# Azure Tables
#

variable "tables" {
  description = <<EOT
A list of table and metadata:
```
tables = [
  {
    name = string (required)
    acls = [      (optional)
      {
        id           = string # e.g. "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"
        permissions  = string # e.g. "rwdl"
        start        = string # e.g. "2019-07-02T09:38:21.0000000Z"
        expiry       = string # e.g. "2019-07-02T10:38:21.0000000Z"
      },
    ]
    partition_key = string      (optional)
    row_key       = string      (optional)
    entity        = map(string) (optional)
  },
]
```
EOT
  type        = list(any)
  default     = []
}

#
# Local Users
#

variable "local_users" {
  description = <<EOT
A list of users and permissions:
```
local_users = {
  "name" = {
    home_directory       = string
    ssh_key_enabled      = bool # false
    ssh_password_enabled = bool # false
    ssh_authorized_keys  = [
      {
        description = string
        key         = string
      },
    ]
    permission_scopes = [
      {
        service       = string # blob or file
        resource_name = string
        permissions = {
          create = bool # false
          delete = bool # false
          list   = bool # false
          read   = bool # false
          write  = bool # false
        }
      },
    ]
  }
}
```
EOT
  type        = map(any)
  default     = {}
}

#
# Diagnostic log
#

# --- Storage Account ---
variable "diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  log                            = list(string) # []
  metric                         = list(string) # ["Transaction"]
  storage_account_id             = string 
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "Dedicated" or null
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
},
```
EOT
  type        = list(any)
  default     = []
}

# --- Blob ---
variable "blob_diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  log                            = list(string) # ["StorageRead", "StorageWrite", "StorageDelete"]
  metric                         = list(string) # ["Transaction"]
  storage_account_id             = string 
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "Dedicated" or null
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
},
```
EOT
  type        = list(any)
  default     = []
}

# --- File ---
variable "file_diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  log                            = list(string) # ["StorageRead", "StorageWrite", "StorageDelete"]
  metric                         = list(string) # ["Transaction"]
  storage_account_id             = string 
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "Dedicated" or null
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
},
```
EOT
  type        = list(any)
  default     = []
}

# --- Queue ---
variable "queue_diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  log                            = list(string) # ["StorageRead", "StorageWrite", "StorageDelete"]
  metric                         = list(string) # ["Transaction"]
  storage_account_id             = string 
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "Dedicated" or null
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
},
```
EOT
  type        = list(any)
  default     = []
}

# --- Table ---
variable "table_diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  log                            = list(string) # ["StorageRead", "StorageWrite", "StorageDelete"]
  metric                         = list(string) # ["Transaction"]
  storage_account_id             = string 
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "Dedicated" or null
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
},
```
EOT
  type        = list(any)
  default     = []
}

#
# Network Rules
#

variable "default_action" {
  description = "Specifies the default action of allow or deny when no other rules match."
  type        = string
  default     = "Allow"

  validation {
    condition     = can(regex("^(Deny|Allow)$", var.default_action))
    error_message = "The valid options are Deny, and Allow."
  }
}

variable "bypass" {
  description = "Specifies whether traffic is bypassed for Logging/Metrics/AzureServices."
  type        = list(string)
  default     = ["None"]
}

variable "ip_rules" {
  description = "List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed."
  type        = list(string)
  default     = []
}

variable "virtual_network_subnet_ids" {
  description = "A list of virtual network subnet ids to to secure the storage account."
  type        = list(string)
  default     = []
}

variable "private_link_accesses" {
  description = <<EOT
List of private endpoints to be granted access to this resource:
```
private_link_accesses = [
  {
    endpoint_resource_id = string (required)
    endpoint_tenant_id   = string (optional) # Defaults to the current tenant id.
  }, {
    ...
  }, ...
]
```
EOT
  type        = list(any)
  default     = []
}

variable "cmk_encryption_enabled" {
  description = "Specify whethere to enable customer managed key encryption."
  type        = bool
  default     = false
}

variable "cmk_key_vault_id" {
  description = "The ID of the Key Vault. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "cmk_key_name" {
  description = "The name of Key Vault Key."
  type        = string
  default     = null
}

variable "cmk_key_version" {
  description = "The version of Key Vault Key. Remove or omit this argument to enable Automatic Key Rotation."
  type        = string
  default     = null
}

variable "cmk_user_assigned_identity_id" {
  description = "The ID of a user assigned identity."
  type        = string
  default     = null
}

#
# Private Endpoint
# 

# --- Blob ---

variable "enable_blob_private_endpoint" {
  description = "Enable private endpoint to the storage ?"
  type        = bool
  default     = false
}

variable "blob_private_dns_zone_id" {
  description = "ID of private DNS zone to register private link."
  type        = string
  default     = null
}

variable "blob_link_snet_id" {
  description = "ID of subnet where private endpoint will be created."
  type        = string
  default     = null
}

variable "blob_pe_name" {
  description = "Name of private endpoint"
  type        = string
  default     = ""
}

# --- File ---

variable "enable_file_private_endpoint" {
  description = "Enable private endpoint to the storage ?"
  type        = bool
  default     = false
}

variable "file_private_dns_zone_id" {
  description = "ID of private DNS zone to register private link."
  type        = string
  default     = null
}

variable "file_link_snet_id" {
  description = "ID of subnet where private endpoint will be created."
  type        = string
  default     = null
}

variable "file_pe_name" {
  description = "Name of private endpoint"
  type        = string
  default     = ""
}

# --- Queue ---

variable "enable_queue_private_endpoint" {
  description = "Enable private endpoint to the storage ?"
  type        = bool
  default     = false
}

variable "queue_private_dns_zone_id" {
  description = "ID of private DNS zone to register private link."
  type        = string
  default     = null
}

variable "queue_link_snet_id" {
  description = "ID of subnet where private endpoint will be created."
  type        = string
  default     = null
}

variable "queue_pe_name" {
  description = "Name of private endpoint"
  type        = string
  default     = ""
}

# --- Table ---

variable "enable_table_private_endpoint" {
  description = "Enable private endpoint to the storage ?"
  type        = bool
  default     = false
}

variable "table_private_dns_zone_id" {
  description = "ID of private DNS zone to register private link."
  type        = string
  default     = null
}

variable "table_link_snet_id" {
  description = "ID of subnet where private endpoint will be created."
  type        = string
  default     = null
}

variable "table_pe_name" {
  description = "Name of private endpoint"
  type        = string
  default     = ""
}
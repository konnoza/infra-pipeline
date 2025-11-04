/*
*
* # Terraform Module for creating storage account
*
*/

data "http" "myip" {
  url = "https://api.ipify.org?format=text"
}

locals {
  myip = data.http.myip.response_body
}

#
# Storage Account
#

resource "azurerm_storage_account" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  account_tier             = var.account_tier             # Standard and Premium
  account_kind             = var.account_kind             # BlobStorage, Storage and StorageV2* | Premium Only = BlockBlobStorage, FileStorage
  account_replication_type = var.account_replication_type # LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS
  access_tier              = var.access_tier              # for account kind = BlobStorage, FileStorage and StorageV2 => Hot and Cool

  enable_https_traffic_only = var.enable_https_traffic_only
  min_tls_version           = var.min_tls_version
  is_hns_enabled            = var.is_hns_enabled # Can be true, if ( account_tier = Standard ) or ( account_tier = Premium and account_kind = BlockBlobStorage )

  edge_zone                       = var.edge_zone
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  nfsv3_enabled                   = var.nfsv3_enabled
  # - `is_hns_enabled = true`, and `enable_https_traffic_only = false`
  #     - `account_tier is Standard` and `account_kind is StorageV2`
  #     - `account_tier is Premium` and `account_kind is BlockBlobStorage`
  # if account_kind = StorageV2, queue_encryption_key_type and table_encryption_key_type can only be Account
  queue_encryption_key_type         = var.queue_encryption_key_type         # Service and Account
  table_encryption_key_type         = var.table_encryption_key_type         # Service and Account
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled # true when ( account_kind = StorageV2 ) or ( account_tier = Premium and account_kind = BlockBlobStorage )
  large_file_share_enabled          = var.account_tier == "Premium" ? true : var.large_file_share_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  sftp_enabled                      = var.sftp_enabled # require is_hns_enabled=true
  allowed_copy_scope                = var.allowed_copy_scope
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  public_network_access_enabled     = var.public_network_access_enabled

  # REF: https://docs.microsoft.com/en-us/azure/storage/common/network-routing-preference
  dynamic "routing" {
    for_each = var.routing_publish_internet_endpoints == null && var.routing_publish_microsoft_endpoints == null && var.routing_choice == null ? [] : ["create"]
    content {
      publish_internet_endpoints  = var.routing_publish_internet_endpoints
      publish_microsoft_endpoints = var.routing_publish_microsoft_endpoints
      choice                      = var.routing_choice
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : ["create"]
    content {
      type         = var.identity_type # "SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  dynamic "static_website" {
    for_each = var.static_website_enabled ? ["create"] : []
    content {
      index_document     = var.static_website_index_document
      error_404_document = var.static_website_error_404_document
    }
  }

  dynamic "custom_domain" {
    for_each = var.custom_domain_name == null ? [] : ["create"]
    content {
      name          = var.custom_domain_name
      use_subdomain = var.custom_domain_use_subdomain
    }
  }

  dynamic "blob_properties" {
    for_each = var.account_kind == "FileStorage" ? [] : ["create"]
    content {
      dynamic "cors_rule" {
        for_each = var.blob_properties_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      delete_retention_policy {
        days = var.blob_properties_delete_retention_policy_days
      }
      container_delete_retention_policy {
        days = var.blob_properties_container_delete_retention_policy_days
      }
      versioning_enabled            = var.blob_properties_versioning_enabled
      change_feed_enabled           = var.blob_properties_change_feed_enabled
      change_feed_retention_in_days = var.blob_properties_change_feed_retention_in_days
      default_service_version       = var.blob_properties_default_service_version
      last_access_time_enabled      = var.blob_properties_last_access_time_enabled
      # Require 
      # - `delete_retention_policy` is set
      # - `versioning_enabled` is `true`
      # - `change_feed_enabled` is `true`
      dynamic "restore_policy" {
        for_each = var.blob_properties_restore_policy_enabled ? ["create"] : []
        content {
          days = var.blob_properties_restore_policy_days # should less than `delete_retention_policy`
        }
      }
    }
  }

  dynamic "queue_properties" { # Only when account_kind = BlobStorage
    for_each = var.account_kind == "BlobStorage" ? ["create"] : []
    content {
      dynamic "cors_rule" {
        for_each = var.queue_properties_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      logging {
        delete                = var.queue_properties_logging_delete
        read                  = var.queue_properties_logging_read
        version               = var.queue_properties_logging_version
        write                 = var.queue_properties_logging_write
        retention_policy_days = var.queue_properties_logging_retention_policy_days
      }
      minute_metrics {
        enabled               = var.queue_properties_minute_metrics_enabled
        version               = var.queue_properties_minute_metrics_version
        include_apis          = var.queue_properties_minute_metrics_include_apis
        retention_policy_days = var.queue_properties_minute_metrics_retention_policy_days
      }
      hour_metrics {
        enabled               = var.queue_properties_hour_metrics_enabled
        version               = var.queue_properties_hour_metrics_version
        include_apis          = var.queue_properties_hour_metrics_include_apis
        retention_policy_days = var.queue_properties_hour_metrics_retention_policy_days
      }
    }
  }

  share_properties {
    dynamic "cors_rule" {
      for_each = var.share_properties_cors_rules
      content {
        allowed_headers    = cors_rule.value.allowed_headers
        allowed_methods    = cors_rule.value.allowed_methods
        allowed_origins    = cors_rule.value.allowed_origins
        exposed_headers    = cors_rule.value.exposed_headers
        max_age_in_seconds = cors_rule.value.max_age_in_seconds
      }
    }
    retention_policy {
      days = var.share_properties_retention_policy_days
    }
    dynamic "smb" {
      for_each = length(concat(var.share_properties_smb_versions, var.share_properties_smb_authentication_types, var.share_properties_smb_kerberos_ticket_encryption_type, var.share_properties_smb_channel_encryption_type)) > 0 ? ["create"] : []
      content {
        versions                        = var.share_properties_smb_versions
        authentication_types            = var.share_properties_smb_authentication_types
        kerberos_ticket_encryption_type = var.share_properties_smb_kerberos_ticket_encryption_type
        channel_encryption_type         = var.share_properties_smb_channel_encryption_type
        multichannel_enabled            = var.share_properties_smb_multichannel_enabled # Premium
      }
    }

  }

  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication_enabled ? ["create"] : []
    content {
      directory_type = var.azure_files_authentication_directory_type
      dynamic "active_directory" {
        for_each = var.azure_files_authentication_directory_type == "AD" ? ["create"] : []
        content {
          storage_sid         = var.azure_files_authentication_ad_storage_sid
          domain_name         = var.azure_files_authentication_ad_domain_name
          domain_sid          = var.azure_files_authentication_ad_domain_sid
          domain_guid         = var.azure_files_authentication_ad_domain_guid
          forest_name         = var.azure_files_authentication_ad_forest_name
          netbios_domain_name = var.azure_files_authentication_ad_netbios_domain_name
        }
      }
    }
  }

  dynamic "immutability_policy" {
    for_each = var.immutability_policy_enabled ? ["create"] : []
    content {
      allow_protected_append_writes = var.immutability_policy_allow_protected_append_writes
      state                         = var.immutability_policy_state
      period_since_creation_in_days = var.immutability_policy_period_since_creation_in_days
    }
  }

  dynamic "sas_policy" {
    for_each = var.sas_policy_enabled ? ["create"] : []
    content {
      expiration_period = var.sas_policy_expiration_period # DD.HH:MM:SS
      expiration_action = var.sas_policy_expiration_action # Log
    }
  }

  dynamic "network_rules" {
    for_each = var.nfsv3_enabled ? ["create"] : []
    content {
      default_action             = var.default_action
      bypass                     = var.bypass
      ip_rules                   = concat(var.ip_rules, [local.myip])
      virtual_network_subnet_ids = var.virtual_network_subnet_ids

      dynamic "private_link_access" {
        for_each = var.private_link_accesses
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
        }
      }
    }
  }
}

resource "azurerm_storage_account_network_rules" "main" {
  count = var.nfsv3_enabled ? 0 : 1

  storage_account_id         = azurerm_storage_account.main.id
  default_action             = var.default_action
  bypass                     = var.bypass
  ip_rules                   = concat(var.ip_rules, [local.myip])
  virtual_network_subnet_ids = var.virtual_network_subnet_ids

  dynamic "private_link_access" {
    for_each = var.private_link_accesses
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
    }
  }
}

resource "azurerm_storage_account_customer_managed_key" "main" {
  count                     = var.cmk_encryption_enabled ? 1 : 0
  storage_account_id        = azurerm_storage_account.main.id
  key_vault_id              = var.cmk_key_vault_id
  key_name                  = var.cmk_key_name
  key_version               = var.cmk_key_version
  user_assigned_identity_id = var.cmk_user_assigned_identity_id
}

#
# Azure Files
# 

resource "azurerm_storage_share" "main" {
  count = length(var.shares)

  name                 = var.shares[count.index].name
  storage_account_name = azurerm_storage_account.main.name
  quota                = var.shares[count.index].quota_in_gb
  access_tier          = lookup(var.shares[count.index], "access_tier", null)
  enabled_protocol     = lookup(var.shares[count.index], "enabled_protocol", "SMB")
  metadata             = lookup(var.shares[count.index], "metadata", {})

  dynamic "acl" {
    for_each = lookup(var.shares[count.index], "acls", toset([]))
    content {
      id = acl.value.id
      access_policy {
        permissions = acl.value.permissions
        start       = acl.value.start
        expiry      = acl.value.expiry
      }
    }
  }

  depends_on = [
    azurerm_storage_account.main,
  ]
}

#
# Azure Blob
# 

resource "azurerm_storage_container" "main" {
  count = length(var.blobs)

  name                  = var.blobs[count.index].name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = lookup(var.blobs[count.index], "access_type", "private")
  metadata              = lookup(var.blobs[count.index], "metadata", {})

  depends_on = [
    azurerm_storage_account.main,
  ]
}

#
# Azure Queue
#

resource "azurerm_storage_queue" "main" {
  count = length(var.queues)

  name                 = var.queues[count.index].name
  storage_account_name = azurerm_storage_account.main.name
  metadata             = lookup(var.queues[count.index], "metadata", {})

  depends_on = [
    azurerm_storage_account.main,
  ]
}

#
# Azure Table
#

locals {
  table_entities = {
    for x in var.tables : x.name => x if lookup(x, "partition_key", null) != null
  }
}

resource "azurerm_storage_table" "main" {
  for_each = { for table in var.tables : table.name => table }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.main.name

  dynamic "acl" {
    for_each = lookup(each.value, "acls", toset([]))
    content {
      id = acl.value.id
      access_policy {
        permissions = acl.value.permissions
        start       = acl.value.start
        expiry      = acl.value.expiry
      }
    }
  }

  depends_on = [
    azurerm_storage_account.main,
  ]
}

resource "azurerm_storage_table_entity" "main" {
  for_each = local.table_entities

  storage_table_id = azurerm_storage_table.main[each.key].id
  partition_key    = each.value.partition_key
  row_key          = each.value.row_key
  entity           = each.value.entity

  depends_on = [
    azurerm_storage_table.main,
  ]
}

#
# Local Users (SFTP) 
# 

resource "azurerm_storage_account_local_user" "main" {
  for_each = var.local_users

  storage_account_id = azurerm_storage_account.main.id
  name               = each.key

  home_directory       = lookup(each.value, "home_directory", null)
  ssh_key_enabled      = lookup(each.value, "ssh_key_enabled", false)
  ssh_password_enabled = lookup(each.value, "ssh_password_enabled", false)
  dynamic "ssh_authorized_key" {
    for_each = toset(lookup(each.value, "ssh_authorized_keys", []))
    content {
      description = ssh_authorized_key.key.description
      key         = ssh_authorized_key.key.key
    }
  }
  dynamic "permission_scope" {
    for_each = toset(lookup(each.value, "permission_scopes", []))
    content {
      service       = permission_scope.key.service
      resource_name = permission_scope.key.resource_name
      permissions {
        create = lookup(permission_scope.key.permissions, "create", false)
        delete = lookup(permission_scope.key.permissions, "delete", false)
        list   = lookup(permission_scope.key.permissions, "list", false)
        read   = lookup(permission_scope.key.permissions, "read", false)
        write  = lookup(permission_scope.key.permissions, "write", false)
      }
    }
  }
}

#
# Diagnostic Log
#

# --- Storage Account ---

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = length(var.diagnostic_settings)

  name               = "diag-${var.name}-${var.diagnostic_settings[count.index].suffix_name}"
  target_resource_id = azurerm_storage_account.main.id

  storage_account_id             = lookup(var.diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.diagnostic_settings[count.index], "log_analytics_destination_type", "Dedicated")
  eventhub_authorization_rule_id = lookup(var.diagnostic_settings[count.index], "eventhub_authorization_rule_id", null)
  eventhub_name                  = lookup(var.diagnostic_settings[count.index], "eventhub_name", null)
  partner_solution_id            = lookup(var.diagnostic_settings[count.index], "partner_solution_id", null)

  # enabled_log
  dynamic "enabled_log" {
    for_each = lookup(var.diagnostic_settings[count.index], "enabled_logs", toset([]))

    content {
      category = enabled_log.value
    }
  }

  # enabled_category
  dynamic "enabled_log" {
    for_each = lookup(var.diagnostic_settings[count.index], "enabled_categories", toset([]))

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.diagnostic_settings[count.index], "metric", toset([]))

    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [metric, enabled_log, log_analytics_destination_type, ]
  }
}

# --- Blob ---

resource "azurerm_monitor_diagnostic_setting" "blob" {
  count = length(var.blob_diagnostic_settings)

  name               = "diag-${var.name}-${var.blob_diagnostic_settings[count.index].suffix_name}"
  target_resource_id = "${azurerm_storage_account.main.id}/blobServices/default"

  storage_account_id             = lookup(var.blob_diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.blob_diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.blob_diagnostic_settings[count.index], "log_analytics_destination_type", "Dedicated")
  eventhub_authorization_rule_id = lookup(var.blob_diagnostic_settings[count.index], "eventhub_authorization_rule_id", null)
  eventhub_name                  = lookup(var.blob_diagnostic_settings[count.index], "eventhub_name", null)
  partner_solution_id            = lookup(var.blob_diagnostic_settings[count.index], "partner_solution_id", null)

  # enabled_log
  dynamic "enabled_log" {
    for_each = lookup(var.blob_diagnostic_settings[count.index], "enabled_logs", toset([]))

    content {
      category = enabled_log.value
    }
  }

  # enabled_category
  dynamic "enabled_log" {
    for_each = lookup(var.blob_diagnostic_settings[count.index], "enabled_categories", toset([]))

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.blob_diagnostic_settings[count.index], "metric", toset([]))

    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [metric, enabled_log, log_analytics_destination_type, ]
  }
}

# --- File ---

resource "azurerm_monitor_diagnostic_setting" "file" {
  count = length(var.file_diagnostic_settings)

  name               = "diag-${var.name}-${var.file_diagnostic_settings[count.index].suffix_name}"
  target_resource_id = "${azurerm_storage_account.main.id}/fileServices/default"

  storage_account_id             = lookup(var.file_diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.file_diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.file_diagnostic_settings[count.index], "log_analytics_destination_type", "Dedicated")
  eventhub_authorization_rule_id = lookup(var.file_diagnostic_settings[count.index], "eventhub_authorization_rule_id", null)
  eventhub_name                  = lookup(var.file_diagnostic_settings[count.index], "eventhub_name", null)
  partner_solution_id            = lookup(var.file_diagnostic_settings[count.index], "partner_solution_id", null)

  # enabled_log
  dynamic "enabled_log" {
    for_each = lookup(var.file_diagnostic_settings[count.index], "enabled_logs", toset([]))

    content {
      category = enabled_log.value
    }
  }

  # enabled_category
  dynamic "enabled_log" {
    for_each = lookup(var.file_diagnostic_settings[count.index], "enabled_categories", toset([]))

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.file_diagnostic_settings[count.index], "metric", toset([]))

    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [metric, enabled_log, log_analytics_destination_type, ]
  }
}

# --- Queue ---

resource "azurerm_monitor_diagnostic_setting" "queue" {
  count = length(var.queue_diagnostic_settings)

  name               = "diag-${var.name}-${var.queue_diagnostic_settings[count.index].suffix_name}"
  target_resource_id = "${azurerm_storage_account.main.id}/queueServices/default"

  storage_account_id             = lookup(var.queue_diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.queue_diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.queue_diagnostic_settings[count.index], "log_analytics_destination_type", "Dedicated")
  eventhub_authorization_rule_id = lookup(var.queue_diagnostic_settings[count.index], "eventhub_authorization_rule_id", null)
  eventhub_name                  = lookup(var.queue_diagnostic_settings[count.index], "eventhub_name", null)
  partner_solution_id            = lookup(var.queue_diagnostic_settings[count.index], "partner_solution_id", null)

  # enabled_log
  dynamic "enabled_log" {
    for_each = lookup(var.queue_diagnostic_settings[count.index], "enabled_logs", toset([]))

    content {
      category = enabled_log.value
    }
  }

  # enabled_category
  dynamic "enabled_log" {
    for_each = lookup(var.queue_diagnostic_settings[count.index], "enabled_categories", toset([]))

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.queue_diagnostic_settings[count.index], "metric", toset([]))

    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [metric, enabled_log, log_analytics_destination_type, ]
  }
}

# --- Table ---

resource "azurerm_monitor_diagnostic_setting" "table" {
  count = length(var.table_diagnostic_settings)

  name               = "diag-${var.name}-${var.table_diagnostic_settings[count.index].suffix_name}"
  target_resource_id = "${azurerm_storage_account.main.id}/tableServices/default"

  storage_account_id             = lookup(var.table_diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.table_diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.table_diagnostic_settings[count.index], "log_analytics_destination_type", "Dedicated")
  eventhub_authorization_rule_id = lookup(var.table_diagnostic_settings[count.index], "eventhub_authorization_rule_id", null)
  eventhub_name                  = lookup(var.table_diagnostic_settings[count.index], "eventhub_name", null)
  partner_solution_id            = lookup(var.table_diagnostic_settings[count.index], "partner_solution_id", null)

  # enabled_log
  dynamic "enabled_log" {
    for_each = lookup(var.table_diagnostic_settings[count.index], "enabled_logs", toset([]))

    content {
      category = enabled_log.value
    }
  }

  # enabled_category
  dynamic "enabled_log" {
    for_each = lookup(var.table_diagnostic_settings[count.index], "enabled_categories", toset([]))

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.table_diagnostic_settings[count.index], "metric", toset([]))

    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [metric, enabled_log, log_analytics_destination_type, ]
  }
}

#
# Private Endpoint
#

# --- Blob ---

resource "azurerm_private_endpoint" "st_blob" {
  count = var.enable_blob_private_endpoint ? 1 : 0

  name                = var.blob_pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.blob_link_snet_id

  private_dns_zone_group {
    name                 = split("/", var.blob_private_dns_zone_id)[8]
    private_dns_zone_ids = [var.blob_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.blob_pe_name}-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
  }

  tags = var.tags
}

# --- File ---

resource "azurerm_private_endpoint" "st_file" {
  count = var.enable_file_private_endpoint ? 1 : 0

  name                = var.file_pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.file_link_snet_id

  private_dns_zone_group {
    name                 = split("/", var.file_private_dns_zone_id)[8]
    private_dns_zone_ids = [var.file_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.file_pe_name}-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["file"]
  }

  tags = var.tags
}

# --- Queues ---

resource "azurerm_private_endpoint" "st_queue" {
  count = var.enable_queue_private_endpoint ? 1 : 0

  name                = var.queue_pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.queue_link_snet_id

  private_dns_zone_group {
    name                 = split("/", var.queue_private_dns_zone_id)[8]
    private_dns_zone_ids = [var.queue_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.queue_pe_name}-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["queue"]
  }

  tags = var.tags
}

# --- Table ---

resource "azurerm_private_endpoint" "st_table" {
  count = var.enable_table_private_endpoint ? 1 : 0

  name                = var.table_pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.table_link_snet_id

  private_dns_zone_group {
    name                 = split("/", var.table_private_dns_zone_id)[8]
    private_dns_zone_ids = [var.table_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.table_pe_name}-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["table"]
  }

  tags = var.tags
}
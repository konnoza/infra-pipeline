/*
*
* # Terraform Module to Create Azure Container Registry
*
*/

#
# Azure Container Registry
#

resource "azurerm_container_registry" "main" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
  anonymous_pull_enabled        = contains(["Standard", "Premium"], var.sku) ? var.anonymous_pull_enabled : false
  network_rule_bypass_option    = var.network_rule_bypass_option

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? ["create"] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }
  dynamic "encryption" {
    for_each = var.encryption_enabled ? ["create"] : []
    content {
      key_vault_key_id   = var.encryption_key_vault_key_id
      identity_client_id = var.encryption_identity_client_id
    }
  }

  # Premium SKU
  zone_redundancy_enabled   = var.sku == "Premium" ? var.zone_redundancy_enabled : null
  export_policy_enabled     = var.sku == "Premium" ? var.export_policy_enabled : null # false -> public_network_access_enabled=false
  data_endpoint_enabled     = var.sku == "Premium" ? var.data_endpoint_enabled : null
  quarantine_policy_enabled = var.sku == "Premium" ? var.quarantine_policy_enabled : null

  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_policy_enabled ? ["create"] : []
    content {
      enabled = true
      days    = var.retention_policy_in_days
    }
  }

  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy_enabled ? ["create"] : []
    content {
      enabled = true
    }
  }

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = lookup(georeplications.value, "regional_endpoint_enabled", false)
      zone_redundancy_enabled   = lookup(georeplications.value, "zone_redundancy_enabled", false)
      tags                      = var.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = lookup(var.network_rule_set, "default_action", "Allow") == "Deny" ? ["create"] : []
    content {
      default_action = lookup(var.network_rule_set, "default_action", "Deny")
      dynamic "ip_rule" {
        for_each = lookup(var.network_rule_set, "ip_rules", toset([]))
        content {
          action   = lookup(ip_rule.value, "action", "Allow")
          ip_range = ip_rule.value["ip_range"]
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#
# Private Endpoint
#

resource "azurerm_private_endpoint" "main" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = var.pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.link_snet_id
  tags                = var.tags

  private_dns_zone_group {
    name                 = split("/", var.private_dns_zone_id)[8]
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.pe_name}-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
  }
}

#
# Diagnostic Log
# 

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = length(var.diagnostic_settings)

  name               = "diag-${var.name}-${var.diagnostic_settings[count.index].suffix_name}"
  target_resource_id = azurerm_container_registry.main.id

  storage_account_id             = lookup(var.diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.diagnostic_settings[count.index], "log_analytics_destination_type", "AzureDiagnostics")
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
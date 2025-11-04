/*
*
* # Terraform Module for creating Azure Key Vault
*
*/

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "https://ifconfig.me"
  request_headers = {
    user-agent = "curl/7.68.0"
  }
}

locals {
  myip = data.http.myip.response_body
}

#
# Azure Key Vault
#

resource "azurerm_key_vault" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization

  dynamic "network_acls" {
    for_each = var.enable_network_acls ? ["acl"] : []

    content {
      bypass                     = var.network_acls_allow_trusted_microsoft_services ? "AzureServices" : "None"
      default_action             = var.network_acls_default_action
      ip_rules                   = var.network_acls_allow_my_current_ip ? concat(var.network_acls_ip_rules, ["${local.myip}/32"]) : var.network_acls_ip_rules
      virtual_network_subnet_ids = var.network_acls_virtual_network_subnet_ids
    }
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update",
    ]
    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
    ]
    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set",
    ]
    storage_permissions = [
      "Backup",
      "Delete",
      "DeleteSAS",
      "Get",
      "GetSAS",
      "List",
      "ListSAS",
      "Purge",
      "Recover",
      "RegenerateKey",
      "Restore",
      "Set",
      "SetSAS",
      "Update",
    ]
  }

  dynamic "access_policy" {
    for_each = var.access_policies
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = lookup(access_policy.value, "certificate_permissions", [])
      key_permissions         = lookup(access_policy.value, "key_permissions", [])
      secret_permissions      = lookup(access_policy.value, "secret_permissions", [])
      storage_permissions     = lookup(access_policy.value, "storage_permissions", [])
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [access_policy]
  }
}

resource "azurerm_key_vault_certificate_contacts" "main" {
  key_vault_id = azurerm_key_vault.main.id

  dynamic "contact" {
    for_each = var.contact_email != "" ? ["create_contact"] : []

    content {
      email = var.contact_email
      name  = var.contact_fullname
    }
  }

  dynamic "contact" {
    for_each = var.contacts
    content {
      email = contact.value["email"]
      name  = lookup(contact.value, "name", null)
      phone = lookup(contact.value, "phone", null)
    }
  }
}

# ----- Private Endpoint ------------------------------------------------------------------------------

# REF: find "subresource_names" => https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "main" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = var.pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.link_snet_id

  private_dns_zone_group {
    name                 = split("/", var.private_dns_zone_id)[8]
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.pe_name}-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
  }

  tags = var.tags
}

#
# Enable diagnostic log
#

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = length(var.diagnostic_settings)

  name               = "diag-${var.name}-${var.diagnostic_settings[count.index].suffix_name}"
  target_resource_id = azurerm_key_vault.main.id

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
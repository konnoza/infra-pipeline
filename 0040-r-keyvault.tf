#
# Naming
#

module "naming_keyvault" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    {
      resource_type  = "key_vault" # 0
      resource_name  = var.project_prefix
      instance_start = 1
      instance_count = 1
    },
    {
      resource_type  = "private_endpoint" # 1
      resource_name  = "${var.project_prefix}KeyVault"
      instance_start = 1
      instance_count = 1
    },
  ]
}

locals {
  key_vault_name                  = module.naming_keyvault.result.0.names.0
  key_vault_private_endpoint_name = module.naming_keyvault.result.1.names.0
}

#
# Resources
#

# Private DNS Zone

data "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_private_dns_zone.main]
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "link-${local.virtual_network_name}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = module.vnet.vnet_id

  depends_on = [
    module.vnet,
    azurerm_private_dns_zone.main
  ]
}

# Role Assignments (RBAC)
# RBAC DEV
resource "azurerm_role_assignment" "id-iac-secret" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "id-aks-secret" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "id-aks-certificate" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}


# Key Vault

module "keyvault" {
  source = "./modules/keyvault"

  name                = local.key_vault_name
  resource_group_name = local.resource_group_name
  location            = var.region
  sku_name            = var.keyvault_sku

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  purge_protection_enabled        = var.environment == "prd" ? true : false

  enable_network_acls                           = false
  network_acls_allow_trusted_microsoft_services = true
  network_acls_default_action                   = "Deny"
  network_acls_allow_my_current_ip              = true
  network_acls_ip_rules                         = []
  network_acls_virtual_network_subnet_ids       = []

  enable_private_endpoint = true
  private_dns_zone_id     = data.azurerm_private_dns_zone.keyvault.id
  link_snet_id            = module.vnet.vnet_subnets[[for i, v in var.subnet_names : i if replace(v, "PrivateEndpoint", "") != v][0]]
  pe_name                 = local.key_vault_private_endpoint_name

  contact_email    = var.contact_email
  contact_fullname = var.contact_fullname

  diagnostic_settings = []

  depends_on = [
    azurerm_resource_group.main,
    azurerm_private_dns_zone_virtual_network_link.keyvault,
  ]
}
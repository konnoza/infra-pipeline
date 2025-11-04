#
# Naming
#

module "naming_acr" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    {
      resource_type  = "container_registry" # 0
      resource_name  = var.project_prefix
      instance_start = 1
      instance_count = 1
    },
    {
      resource_type  = "private_endpoint" # 1
      resource_name  = "${var.project_prefix}Acr"
      instance_start = 1
      instance_count = 1
    },
  ]
}

locals {
  container_registry_name                  = module.naming_acr.result.0.names.0
  container_registry_private_endpoint_name = module.naming_acr.result.1.names.0
}

#
# Resources
#

# Private DNS Zone

data "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_private_dns_zone.main]
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "link-${local.virtual_network_name}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.acr.name
  virtual_network_id    = module.vnet.vnet_id

  depends_on = [
    module.vnet,
    azurerm_private_dns_zone.main
  ]
}

# Container Registry

module "acr" {
  source = "./modules/acr/"

  name                = local.container_registry_name
  resource_group_name = local.resource_group_name
  location            = var.region
  sku                 = "Premium"
  admin_enabled       = true

  # Network Rules
  public_network_access_enabled = true
  network_rule_set              = var.network_rule_set

  # Private Endpoint
  enable_private_endpoint = true
  private_dns_zone_id     = data.azurerm_private_dns_zone.acr.id
  link_snet_id            = module.vnet.vnet_subnets[[for i, v in var.subnet_names : i if replace(v, "PrivateEndpoint", "") != v][0]]
  pe_name                 = local.container_registry_private_endpoint_name

  diagnostic_settings = []

  depends_on = [
    azurerm_resource_group.main,
    azurerm_private_dns_zone_virtual_network_link.acr,
  ]
}
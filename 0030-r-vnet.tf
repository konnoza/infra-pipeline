#
# Naming
#

module "naming_vnet" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    {
      resource_type  = "virtual_network" # 0
      resource_name  = var.project_prefix
      instance_start = 1
      instance_count = 1
    },
  ]
}

module "naming_subnet" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    for x in var.subnet_names : {
      "resource_type"  = "subnet"
      "resource_name"  = x
      "instance_start" = 1
      "instance_count" = 1
    }
  ]
}

module "naming_routable" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    for x in var.subnet_names : {
      "resource_type"  = "route_table"
      "resource_name"  = x
      "instance_start" = 1
      "instance_count" = 1
    }
  ]
}

module "naming_nsg" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    for x in var.subnet_names : {
      "resource_type"  = "network_security_group"
      "resource_name"  = x
      "instance_start" = 1
      "instance_count" = 1
    }
  ]
}

locals {
  virtual_network_name = module.naming_vnet.result.0.names.0
  subnet_names = [
    for x in module.naming_subnet.result : (
      replace(x.names.0, "GatewaySubnet", "") != x.names.0 ? "GatewaySubnet" : (
        replace(x.names.0, "AzureBastionSubnet", "") != x.names.0 ? "AzureBastionSubnet" : (
          replace(x.names.0, "AzureFirewallSubnet", "") != x.names.0 ? "AzureFirewallSubnet" : (
            x.names.0
          )
        )
      )
    )
  ]
  nsg_names         = module.naming_nsg.result.*.names.0
  route_table_names = module.naming_routable.result.*.names.0
}

#
# Resources
#

# Virtual Network

module "vnet" {
  source = "./modules/vnet/"

  vnet_name           = local.virtual_network_name
  vnet_location       = var.region
  resource_group_name = azurerm_resource_group.main.name

  address_space                                         = var.vnet_address
  dns_servers                                           = var.dns_servers
  subnet_names                                          = local.subnet_names
  subnet_prefixes                                       = var.subnet_prefixes
  subnet_private_endpoint_network_policies              = var.subnet_private_endpoint_network_policies
  subnet_private_link_service_network_policies_enableds = var.subnet_private_link_service_network_policies_enableds
  subnet_service_endpoints                              = var.subnet_service_endpoints
  subnet_delegations                                    = var.subnet_delegations
  nsg_names                                             = local.nsg_names
  nsg_enableds                                          = var.nsg_enableds
  nsg_default_rules_attaches                            = var.nsg_default_rules_attaches
  nsg_custom_rules                                      = var.nsg_custom_rules
  route_table_names                                     = local.route_table_names
  route_table_enableds                                  = var.route_table_enableds
  routes                                                = var.routes

  depends_on = [
    azurerm_resource_group.main,
  ]
}

# Private DNS Zone Links
# locals {
#   linked_private_dns_zone_ids = { for x in var.linked_private_dns_zone_ids : x.name => x }
# }
# resource "azurerm_private_dns_zone_virtual_network_link" "pdns" {
#   for_each = local.linked_private_dns_zone_ids

#   name                  = "link-${local.virtual_network_name}"
#   resource_group_name   = each.value.resource_group
#   private_dns_zone_name = each.key
#   virtual_network_id    = module.vnet.vnet_id

#   depends_on = [
#     module.vnet,
#   ]
# }
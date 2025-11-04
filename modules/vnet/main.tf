/*
*
* # Terraform Module to Create Networking [ VNET / SUBNET / NSG / ROUTE TABLE ]
*
*/

#
# VNET
#

resource "azurerm_virtual_network" "vnet" {
  name                    = var.vnet_name
  resource_group_name     = var.resource_group_name
  location                = var.vnet_location
  address_space           = var.address_space
  dns_servers             = var.dns_servers
  bgp_community           = var.bgp_community
  edge_zone               = var.edge_zone
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  tags                    = var.tags

  # https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-encryption-overview
  dynamic "encryption" {
    for_each = var.encryption_enforcement == null ? [] : ["create"]
    content {
      enforcement = var.encryption_enforcement # DropUnencrypted, AllowUnencrypted
    }
  }

  # lifecycle {
  #   ignore_changes = [
  #     ddos_protection_plan,
  #   ]
  # }
}

#
# SUBNET
#

resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_names)

  name                                          = var.subnet_names[count.index]
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = split(",", var.subnet_prefixes[count.index])
  service_endpoints                             = try(var.subnet_service_endpoints[count.index], [])
  service_endpoint_policy_ids                   = try(var.subnet_service_endpoint_policy_ids[count.index], null)
  private_endpoint_network_policies             = try(var.subnet_private_endpoint_network_policies[count.index], "Enabled")
  private_link_service_network_policies_enabled = try(var.subnet_private_link_service_network_policies_enableds[count.index], true)

  dynamic "delegation" {
    for_each = try(var.subnet_delegations[count.index].name, null) != null ? ["create"] : []
    content {
      name = replace(var.subnet_delegations[count.index].name, "/", ".")
      service_delegation {
        name    = var.subnet_delegations[count.index].name
        actions = var.subnet_delegations[count.index].actions
      }
    }
  }
}

locals {
  subnet_ids             = { for i, v in azurerm_subnet.subnet : i => v.id }
  nsg_to_be_created      = { for i, v in var.nsg_names : i => v if var.nsg_enableds[i] }
  nsg_with_default_rules = { for i, v in var.nsg_default_rules_attaches : i => v if var.nsg_enableds[i] && var.nsg_default_rules_attaches[i] }
  nsg_with_custom_rules = {
    for x in flatten([
      for k, v in var.nsg_custom_rules :
      [for m, n in v : merge({ subnet = k, name = m, key = "${k}-${n.priority}-${m}" }, n)] if length(v) > 0 && var.nsg_enableds[k]
    ]) : x.key => x
  }
  rt_to_be_created = { for i, v in var.route_table_names : i => v if var.route_table_enableds[i] }
  rt_with_custom_routes = {
    for x in flatten([
      for k, v in var.routes :
      [for m, n in v : merge({ subnet = k, name = m, key = "${k}-${m}" }, n)] if length(v) > 0 && var.route_table_enableds[k]
    ]) : x.key => x
  }
}

#
# NSG
#

resource "azurerm_network_security_group" "subnet" {
  for_each = local.nsg_to_be_created

  name                = each.value
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  depends_on = [
    azurerm_subnet.subnet,
  ]
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each = local.nsg_to_be_created

  subnet_id                 = local.subnet_ids[each.key]
  network_security_group_id = azurerm_network_security_group.subnet[each.key].id
}

# Default 

resource "azurerm_network_security_rule" "DenyOtherSubnetsInBound" {
  for_each = local.nsg_with_default_rules

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnet[each.key].name
  name                        = "DenyOtherSubnetsInBound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  depends_on = [
    azurerm_network_security_group.subnet,
  ]
}

resource "azurerm_network_security_rule" "AllowAzureLoadBalancerInBound" {
  for_each = local.nsg_with_default_rules

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnet[each.key].name
  name                        = "AllowAzureLoadBalancerInBound"
  priority                    = 4095
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"

  depends_on = [
    azurerm_network_security_group.subnet,
  ]
}

resource "azurerm_network_security_rule" "AllowSubnetInBound" {
  for_each = local.nsg_with_default_rules

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnet[each.key].name
  name                        = "AllowSubnetInBound"
  priority                    = 4094
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = split(",", var.subnet_prefixes[each.key])
  destination_address_prefix  = "*"

  depends_on = [
    azurerm_network_security_group.subnet,
  ]
}

# Custom

resource "azurerm_network_security_rule" "custom" {
  for_each = local.nsg_with_custom_rules

  resource_group_name                        = var.resource_group_name
  network_security_group_name                = azurerm_network_security_group.subnet[each.value.subnet].name
  name                                       = lookup(each.value, "name")
  priority                                   = lookup(each.value, "priority")
  direction                                  = lookup(each.value, "direction", "Inbound")
  access                                     = lookup(each.value, "access", "Allow")
  protocol                                   = lookup(each.value, "protocol", "*")
  source_port_range                          = lookup(each.value, "source_port_range", null)
  source_port_ranges                         = length(lookup(each.value, "source_port_ranges", [])) == 0 ? null : lookup(each.value, "source_port_ranges", null)
  destination_port_range                     = lookup(each.value, "destination_port_range", null)
  destination_port_ranges                    = length(lookup(each.value, "destination_port_ranges", [])) == 0 ? null : lookup(each.value, "destination_port_ranges", null)
  source_address_prefix                      = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes                    = length(lookup(each.value, "source_address_prefixes", [])) == 0 ? null : lookup(each.value, "source_address_prefixes", null)
  source_application_security_group_ids      = lookup(each.value, "source_application_security_group_ids", null)
  destination_address_prefix                 = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes               = length(lookup(each.value, "destination_address_prefixes", [])) == 0 ? null : lookup(each.value, "destination_address_prefixes", null)
  destination_application_security_group_ids = lookup(each.value, "destination_application_security_group_ids", null)

  depends_on = [
    azurerm_network_security_group.subnet,
  ]
}

#
# Route Table
#

resource "azurerm_route_table" "subnet" {
  for_each = local.rt_to_be_created

  name                          = each.value
  location                      = var.vnet_location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true
  tags                          = var.tags

  depends_on = [
    azurerm_subnet.subnet,
  ]
}

resource "azurerm_subnet_route_table_association" "subnet" {
  for_each = local.rt_to_be_created

  subnet_id      = local.subnet_ids[each.key]
  route_table_id = azurerm_route_table.subnet[each.key].id
}

resource "azurerm_route" "subnet" {
  for_each = local.rt_with_custom_routes

  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.subnet[each.value.subnet].name
  name                   = lookup(each.value, "name")
  address_prefix         = lookup(each.value, "address_prefix")
  next_hop_type          = lookup(each.value, "next_hop_type")
  next_hop_in_ip_address = lookup(each.value, "next_hop_in_ip_address", null)

  depends_on = [
    azurerm_route_table.subnet,
  ]
}

#
# Diagnostic Log
#

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = length(var.diagnostic_settings)

  name               = "diag-${var.vnet_name}-${var.diagnostic_settings[count.index].suffix_name}"
  target_resource_id = azurerm_virtual_network.vnet.id

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
    ignore_changes = [enabled_log, metric, log_analytics_destination_type]
  }
}
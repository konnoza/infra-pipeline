variable "resource_group_name" {
  description = "Name of the resource group to be imported."
  type        = string
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default = {
    "managedBy" = "Terraform"
    "warning"   = "Please specify the proper tags"
  }
}

#
# VNET
#

variable "vnet_name" {
  description = "Name of the vnet to create"
  type        = string
}

variable "vnet_location" {
  description = "The location of the vnet to create. Defaults to the location of the resource group."
  type        = string
  default     = "southeastasia"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet. If no values specified, this defaults to Azure DNS."
  type        = list(string)
  default     = []
}

variable "bgp_community" {
  description = "The BGP community attribute in format `<as-number>:<community-value>`. Currently ASN can be only 12076 (Microsoft ASN)."
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created."
  type        = string
  default     = null
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between `4` and `30` minutes."
  type        = number
  default     = null
}

variable "encryption_enforcement" {
  description = "Specifies if the encrypted Virtual Network allows VM that does not support encryption. Possible values are `DropUnencrypted` and `AllowUnencrypted`."
  type        = string
  default     = null
}

#
# SUBNET
#

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = list(any)
  default     = []
}

variable "subnet_service_endpoint_policy_ids" {
  description = "The list of IDs of Service Endpoint Policies to associate with the subnet."
  type        = list(any)
  default     = []
}

variable "subnet_private_endpoint_network_policies" {
  description = "A map of subnet name to enable/disable **private endpoint** network policies on the subnet."
  type        = list(string)
  default     = []
}

variable "subnet_private_link_service_network_policies_enableds" {
  description = "A map of subnet name to enable/disable **private link service** network policies on the subnet."
  type        = list(bool)
  default     = []
}

variable "subnet_delegations" {
  description = <<EOT
A list of map of subnet delegation configuration:
```
subnet_delegations = [
  {
    name = string # az network vnet subnet list-available-delegations --location LOCATION
    actions = list(string) # Microsoft.Network/networkinterfaces/*, Microsoft.Network/virtualNetworks/subnets/action, Microsoft.Network/virtualNetworks/subnets/join/action, Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action and Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action
  },
]
```
EOT
  type        = list(any)
  default     = []
}

#
# NSG
#

variable "nsg_names" {
  description = "List of NSG name to be created if `nsg_enableds` in the same position is `true`."
  type        = list(string)
  default     = []
}

variable "nsg_enableds" {
  description = "List of boolean to indicate which subnet will be attached with the `nsg_names` in the same position."
  type        = list(bool)
  default     = []
}

variable "nsg_default_rules_attaches" {
  description = "List of boolean to indicate which subnet in the same position will be attached with default NSG rules."
  type        = list(bool)
  default     = []
}

variable "nsg_custom_rules" {
  description = <<EOT
List of custom NSG for each subnet in the same position:
```
nsg_custom_rules = [
  {
    "name" = {
      priority                                   = number # 100 - 4096
      direction                                  = string # Inbound, Outbound
      access                                     = string # Allow, Deny
      protocol                                   = string # Tcp, Udp, Icmp, Esp, Ah or *
      source_port_range                          = string
      source_port_ranges                         = list(string)
      destination_port_range                     = string
      destination_port_ranges                    = list(string)
      source_address_prefix                      = string
      source_address_prefixes                    = list(string)
      source_application_security_group_ids      = list(string)
      destination_address_prefix                 = string
      destination_address_prefixes               = list(string)
      destination_application_security_group_ids = list(string)
    },
  },
]
```
EOT
  type        = list(any)
  default     = []
}

#
# ROUTE TABLE
#

variable "route_table_names" {
  description = "List of route table name to be created if `route_table_enableds` in the same position is `true`."
  type        = list(string)
  default     = []
}

variable "route_table_enableds" {
  description = "List of boolean to indicate which subnet will be attached with the `route_table_names` in the same position."
  type        = list(bool)
  default     = []
}

variable "routes" {
  description = <<EOT
List of routes for each subnet in the same position:
```
routes = [
  {
    "name" = {
      address_prefix         = string # CIDR or Azure Service Tags
      next_hop_type          = string # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None
      next_hop_in_ip_address = string # require if `next_hop_type`=`VirtualAppliance`
    },
  },
]
```
EOT
  type        = list(any)
  default     = []
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
  enabled_logs                   = list(string) # ["VMProtectionAlerts",]
  enabled_categories             = list(string) # ["allLogs",]
  metric                         = list(string) # ["AllMetrics",]
  log                            = list(string) # Same as `enabled_logs` but log will be deprecated in AzureRM 4.0
  storage_account_id             = string
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "AzureDiagnostics" or "Dedicated"
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
  partner_solution_id            = string
},
```
EOT
  type        = list(any)
  default     = []
}
##########################
# Network
##########################

variable "vnet_address" {
  description = "IP address space of spoke VNET."
  type        = list(string)
}

variable "dns_servers" {
  description = "The DNS servers to be used with VNET."
  type        = list(string)
  default     = []
}

variable "subnet_names" {
  description = "Name of subnet inside VNET."
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "IP addess space of each subnet."
  type        = list(string)
}

variable "subnet_private_endpoint_network_policies" {
  description = "A map of subnet name to enable/disable private endpoint network policies on the subnet."
  type        = list(string)
  default     = []
}

variable "subnet_private_link_service_network_policies_enableds" {
  description = "A list of subnet name to enable/disable private link service network policies on the subnet."
  type        = list(bool)
  default     = []
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = list(any)
  default     = []
}

variable "subnet_delegations" {
  description = "A list of delegation to be enable on each subnet."
  type        = list(any)
  default     = []
}

variable "nsg_enableds" {
  description = "A list of subnet name to Network Security Group IDs."
  type        = list(bool)
  default     = []
}

variable "nsg_default_rules_attaches" {
  description = "A list of boolean to indicate which subnet in the same position will be attached with default NSG rules."
  type        = list(bool)
  default     = []
}

variable "nsg_custom_rules" {
  description = "A list of custom NSG for each subnet in the same position."
  type        = list(any)
  default     = []
}

variable "route_table_enableds" {
  description = "A list of subnet name to Route table ids."
  type        = list(bool)
  default     = []
}

variable "routes" {
  description = "A list of routes for each subnet in the same position."
  type        = list(any)
  default     = []
}

##########################
# Link Private DNS Zone
##########################

variable "linked_private_dns_zone_ids" {
  description = "A list of Resource Group and Name of Custom Private DNS Zone which will be linked to this VNET."
  type = list(object({
    resource_group = optional(string)
    name           = optional(string)
  }))
  default = []
}

variable "linked_custom_private_dns_zone_ids" {
  description = "A list of Resource Group and Name of Custom Private DNS Zone which will be linked to this VNET."
  type = list(object({
    resource_group = optional(string)
    name           = optional(string)
  }))
  default = []
}
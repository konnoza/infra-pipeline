##########################
# Information
##########################
project_prefix  = "mydemo"
tenant_id       = "38ed0a87-0953-4206-adb3-d9f096bbce82"
subscription_id = "502d2b68-68b7-492d-87a3-a68571a5645a"
region          = "southeastasia"
environment     = "dev"

##########################
# Private DNS Zone
##########################
private_dns_zone_name = [
  "privatelink.azurecr.io",
  "privatelink.blob.core.windows.net",
  "privatelink.vaultcore.azure.net",
]

##########################
# Network
##########################

vnet_address                                          = ["192.168.1.0/26"]
subnet_names                                          = ["AksCluster", "PrivateEndpoint", "Operation",]
subnet_prefixes                                       = ["192.168.1.0/28", "192.168.1.16/28", "192.168.1.32/28",]
subnet_private_endpoint_network_policies              = ["Disabled", "Enabled", "Enabled", ]
subnet_private_link_service_network_policies_enableds = [true, true, true,]
subnet_service_endpoints                              = [[], [], [],]
subnet_delegations                                    = [[], [], [],]
#
# NSG
#
nsg_enableds               = [true, true, true,]
nsg_default_rules_attaches = [true, true, true,]
nsg_custom_rules = [
  {   # AKS
    "rule-allow-Public" = {
      priority                     = 300
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*" # Tcp, Udp, Icmp, Esp, Ah or *
      source_port_range            = "*"
      source_port_ranges           = []
      destination_port_range       = "443"
      destination_port_ranges      = []
      source_address_prefix        = "*"
      source_address_prefixes      = []
      destination_address_prefix   = "*"
      destination_address_prefixes = []
    },
    "AllowAksNetworkInBound" = {
      priority                     = 4093
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_range            = "*"
      source_port_ranges           = []
      destination_port_range       = "*"
      destination_port_ranges      = []
      source_address_prefix        = null
      source_address_prefixes      = ["100.65.0.0/16", "100.64.0.0/16", "172.17.0.0/16"] # AKS Network
      destination_address_prefix   = "*"
      destination_address_prefixes = []
    },
  },
  { # PE
    "rule-allow-AksCluster" = {
      priority                     = 300
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*" # Tcp, Udp, Icmp, Esp, Ah or *
      source_port_range            = "*"
      source_port_ranges           = []
      destination_port_range       = "*"
      destination_port_ranges      = []
      source_address_prefix        = null
      source_address_prefixes      = ["192.168.1.0/28", ]
      destination_address_prefix   = "*"
      destination_address_prefixes = []
    },
    "rule-allow-OperationSubnet" = {
      priority                     = 400
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*" # Tcp, Udp, Icmp, Esp, Ah or *
      source_port_range            = "*"
      source_port_ranges           = []
      destination_port_range       = "*"
      destination_port_ranges      = []
      source_address_prefix        = null
      source_address_prefixes      = ["192.168.1.32/28", ]
      destination_address_prefix   = "*"
      destination_address_prefixes = []
    },
  },
  { # Operation
  }
]
#
# Routes
#
route_table_enableds = [false, false, false,]
routes = [
  {},
  {},
  {},
]

#############################
# keyvault
#############################
keyvault_sku     = "standard"
contact_email    = "nuttapo_de@hotmail.com"
contact_fullname = "Natthapon Suwannapare"

##########################
# storageaccount
##########################

account_tier     = "Standard"
account_kind     = "StorageV2"
pe_blobs_enabled = true

########################
# aks
########################

aks_kubernetes_version = "1.33.3"
aks_sku_tier           = "Free"
# az vm list-skus --location southeastasia --size Standard_DS2 --all --output table
aks_default_node_pool_size                         = "Standard_D4as_v4"
aks_default_node_pool_os_disk_size_gb              = 50
aks_default_node_pool_node_count                   = 1
aks_default_node_pool_min_count                    = null
aks_default_node_pool_max_count                    = null
aks_default_node_pool_upgrade_settings_max_surge   = 1
aks_default_node_pool_availability_zones           = []
aks_default_node_pool_labels                       = null
aks_default_node_pool_only_critical_addons_enabled = true
aks_default_node_pool_enable_auto_scaling          = false

aks_additional_node_pools = {
  "apppool" = {
    mode                         = "User" # System and User
    os_type                      = null
    os_sku                       = "AzureLinux"
    orchestrator_version         = null
    vm_size                      = "Standard_D4as_v4" #"Standard_D4as_v4"
    vnet_subnet_id               = null
    availability_zones           = []
    enable_auto_scaling          = true
    max_count                    = 1
    min_count                    = 0
    node_count                   = null
    priority                     = "Regular" # Regular and Spot
    eviction_policy              = null      # Spot => Deallocate and Delete, Regular => null
    node_labels                  = { "workload" : "app" }
    node_taints                  = []
    os_disk_size_gb              = 100
    os_disk_type                 = "Ephemeral"
    proximity_placement_group_id = null
    upgrade_settings_max_surge   = 1
    tags                         = null
  },
  "monitorpool" = {
    mode                         = "User" # System and User
    os_type                      = null
    os_sku                       = "AzureLinux"
    orchestrator_version         = null
    vm_size                      = "Standard_D4as_v4" #"Standard_D4as_v4"
    vnet_subnet_id               = null
    availability_zones           = []
    enable_auto_scaling          = true
    max_count                    = 1
    min_count                    = 0
    node_count                   = null
    priority                     = "Regular" # Regular and Spot
    eviction_policy              = null      # Spot => Deallocate and Delete, Regular => null
    node_labels                  = { "workload" : "monitor" }
    node_taints                  = []
    os_disk_size_gb              = 100
    os_disk_type                 = "Ephemeral"
    proximity_placement_group_id = null
    upgrade_settings_max_surge   = 1
    tags                         = null
  },
}

########################
# mi
########################
github_organization_name = "konnoza"
github_repository_name   = "app-pipeline"
github_branch            = ["main"]
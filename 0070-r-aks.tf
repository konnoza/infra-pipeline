#
# Naming
#

module "naming_aks" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    {
      resource_type  = "user_assigned_identity" # 0
      resource_name  = "${var.project_prefix}Aks"
      instance_start = 1
      instance_count = 1
    },
    {
      resource_type  = "kubernetes_cluster" # 1
      resource_name  = var.project_prefix
      instance_start = 1
      instance_count = 1
    },
    {
      resource_type  = "route" # 2
      resource_name  = "${var.project_prefix}aks"
      instance_start = 1
      instance_count = 1
    },
  ]
}

locals {
  kubernetes_cluster_user_assigned_identity_name = module.naming_aks.result.0.names.0
  kubernetes_cluster_name                        = module.naming_aks.result.1.names.0
  kubernetes_route_name                          = module.naming_aks.result.2.names.0
  # Refer -> 0030-r-vnet.tf
  kubernetes_route_table_name = module.naming_routable.result.1.names.0
}

#
# Resources
#

# # Private DNS Zone

# data "azurerm_private_dns_zone" "aks" {
#   name                = "privatelink.${var.region}.azmk8s.io"
#   resource_group_name = local.resource_group_name
#   depends_on          = [azurerm_private_dns_zone.main]
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
#   name                  = "link-${local.virtual_network_name}"
#   resource_group_name   = local.resource_group_name
#   private_dns_zone_name = data.azurerm_private_dns_zone.aks.name
#   virtual_network_id    = module.vnet.vnet_id

#   depends_on = [
#     module.vnet,
#     azurerm_private_dns_zone.main
#   ]
# }

# Managed Identity

resource "azurerm_user_assigned_identity" "aks" {
  name                = local.kubernetes_cluster_user_assigned_identity_name
  resource_group_name = local.resource_group_name
  location            = var.region

  depends_on = [
    azurerm_resource_group.main,
  ]
}

# resource "azurerm_role_assignment" "dns_id" {
#   scope                = data.azurerm_private_dns_zone.aks.id
#   role_definition_name = "Private DNS Zone Contributor"
#   principal_id         = azurerm_user_assigned_identity.aks.principal_id
# }

# AKS

module "aks" {
  source = "./modules/aks/"

  tenant_id           = data.azurerm_client_config.current.tenant_id
  resource_group_name = local.resource_group_name
  resource_group_id   = azurerm_resource_group.main.id
  location            = var.region

  cluster_name                    = local.kubernetes_cluster_name
  dns_prefix                      = var.project_prefix
  api_server_authorized_ip_ranges = []
  kubernetes_version              = var.aks_kubernetes_version
  sku_tier                        = var.aks_sku_tier
  automatic_channel_upgrade       = var.aks_automatic_channel_upgrade

  private_cluster_enabled = false

  default_node_pool_name                         = "default"
  default_node_pool_vm_size                      = var.aks_default_node_pool_size
  default_node_pool_vnet_subnet_id               = module.vnet.vnet_subnets[[for i, v in var.subnet_names : i if replace(v, "AksCluster", "") != v][0]]
  default_node_pool_availability_zones           = var.aks_default_node_pool_availability_zones
  default_node_pool_node_labels                  = var.aks_default_node_pool_labels
  default_node_pool_only_critical_addons_enabled = var.aks_default_node_pool_only_critical_addons_enabled
  default_node_pool_os_disk_type                 = "Ephemeral"
  default_node_pool_os_disk_size_gb              = var.aks_default_node_pool_os_disk_size_gb
  default_node_pool_os_sku                       = "AzureLinux"
  default_node_pool_enable_auto_scaling          = var.aks_default_node_pool_enable_auto_scaling
  default_node_pool_node_count                   = var.aks_default_node_pool_node_count
  default_node_pool_min_count                    = var.aks_default_node_pool_min_count
  default_node_pool_max_count                    = var.aks_default_node_pool_max_count
  default_node_pool_upgrade_settings_max_surge   = var.aks_default_node_pool_upgrade_settings_max_surge

  node_pools = var.aks_additional_node_pools

  addon_profile_azure_policy_enabled = true
  addon_profile_oms_agent_enabled    = false
  # addon_profile_oms_agent_log_analytics_workspace_id                     = azurerm_log_analytics_workspace.main.id
  addon_profile_oms_agent_msi_auth_for_monitoring_enabled                = true
  addon_profile_azure_keyvault_secrets_provider_enabled                  = true
  addon_profile_azure_keyvault_secrets_provider_secret_rotation_enabled  = true
  addon_profile_azure_keyvault_secrets_provider_secret_rotation_interval = "3m"
  addon_profile_azure_keyvault_secrets_provider_attach_keyvault_enabled  = true
  addon_profile_azure_keyvault_secrets_provider_attach_keyvault_id       = module.keyvault.id
  # addon_profile_azure_keyvault_secrets_provider_attach_keyvault_cert_perms   = ["Get", "List", "GetIssuers", "ListIssuers", ]
  # addon_profile_azure_keyvault_secrets_provider_attach_keyvault_key_perms    = ["Get", "List", ]
  # addon_profile_azure_keyvault_secrets_provider_attach_keyvault_secret_perms = ["Get", "List", ]
  addon_profile_microsoft_defender_enabled                    = true
  addon_profile_microsoft_defender_log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  addon_profile_workload_identity_enabled                     = true
  addon_profile_oidc_issuer_enabled                           = true
  monitor_metrics_enabled                                     = true
  #Service Mesh Istio 
  addon_profile_service_mesh_profile_enabled = false

  identity_type         = "ManagedIdentity"
  identity_id           = azurerm_user_assigned_identity.aks.id
  identity_principal_id = azurerm_user_assigned_identity.aks.principal_id

  linux_profile_enable                      = true
  linux_profile_admin_username              = "aksadmin"
  linux_profile_public_ssh_key              = ""
  linux_profile_key_vault_storage_enabled   = true
  linux_profile_public_ssh_key_key_vault_id = module.keyvault.id

  network_profile_network_plugin      = "azure"
  network_profile_network_plugin_mode = "overlay"
  network_profile_network_policy      = "calico"
  network_profile_outbound_type       = "loadBalancer"
  # route_table_name                    = local.kubernetes_route_table_name
  # route_name                          = local.kubernetes_route_name

  rbac_enabled                = true
  rbac_admin_group_object_ids = var.aks_rbac_admin_group_object_ids

  enable_attach_acr = true
  acr_id            = module.acr.id

  # Convert to BKK time => Wed @ 3-5 AM | date -d '2022-05-10 20:00 UTC'
  maintenance_window_allowed       = true
  maintenance_window_allowed_day   = "Monday"
  maintenance_window_allowed_hours = [20, 21, ]

  diagnostic_settings = []

  depends_on = [
    azurerm_resource_group.main,
    # azurerm_role_assignment.dns_id,
    azurerm_user_assigned_identity.aks,
    # azurerm_private_dns_zone_virtual_network_link.aks,
  ]
}
#
# Naming 
#

module "naming_prerequisites" {
  source = "./modules/naming/"

  resource_env    = var.environment
  resource_region = var.region
  resource_list = [
    {
      resource_type  = "resource_group" # 0
      resource_name  = var.project_prefix
      instance_start = 1
      instance_count = 1
    },
    {
      resource_type  = "log_analytics_workspace" # 1
      resource_name  = var.project_prefix
      instance_start = 1
      instance_count = 1
    },
  ]
}

locals {
  resource_group_name          = module.naming_prerequisites.result.0.names.0
  log_analytics_workspace_name = module.naming_prerequisites.result.1.names.0
}


# Resources

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.region
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_workspace_name
  location            = var.region
  resource_group_name = azurerm_resource_group.main.name
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  depends_on = [
    azurerm_resource_group.main,
  ]
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "main" {
  for_each = toset(var.private_dns_zone_name)

  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
}

# Get data
data "azurerm_client_config" "current" {}
#
# Naming
#

module "naming_mi" {
  source = "./modules/naming/"

  resource_region = var.region
  resource_env    = var.environment
  resource_list = [
    {
      resource_type  = "user_assigned_identity" # 0
      resource_name  = "${var.project_prefix}GHRunner"
      instance_start = 1
      instance_count = 1
    },
  ]
}

locals {
  github_runner_user_assigned_identity_name = module.naming_mi.result.0.names.0
}

#
# Resources
#

# Managed Identity

resource "azurerm_user_assigned_identity" "github_runner" {
  name                = local.github_runner_user_assigned_identity_name
  resource_group_name = local.resource_group_name
  location            = var.region

  depends_on = [
    azurerm_resource_group.main,
  ]
}

# Role Assignment

resource "azurerm_role_assignment" "github_runner_aks" {
  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_user_assigned_identity.github_runner.principal_id
}

resource "azurerm_role_assignment" "github_runner_acr" {
  for_each             = toset(["AcrPull", "AcrPush", "AcrImageSigner"])
  scope                = module.acr.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.github_runner.principal_id
}

resource "azurerm_federated_identity_credential" "branch" {
  for_each = var.github_branch

  name                = "github-${var.github_organization_name}-${var.github_repository_name}-${each.value}"
  resource_group_name = local.resource_group_name
  subject             = "repo:${var.github_organization_name}/${var.github_repository_name}:ref:refs/heads/${each.value}"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github_runner.id
}
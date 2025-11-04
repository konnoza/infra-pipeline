terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.117.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.3"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
  use_oidc                   = var.use_oidc
  oidc_request_token         = var.oidc_request_token
  oidc_request_url           = var.oidc_request_url
  skip_provider_registration = false

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = var.environment == "prd" ? true : false
    }
    key_vault {
      recover_soft_deleted_key_vaults = var.environment == "prd" ? true : false
      purge_soft_delete_on_destroy    = var.environment == "prd" ? true : false
    }
  }
}

provider "null" {
  # Configuration options
}

provider "random" {
  # Configuration options
}
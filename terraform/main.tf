terraform {
  required_version = "~> 1.14.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
  }

  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data source for current Azure configuration
data "azurerm_client_config" "current" {}

# Used as SQL AAD admin to allow GitHub Actions to create database users
data "azurerm_user_assigned_identity" "github_actions" {
  name                = "id-ccworkshop-github"
  resource_group_name = var.nonprod_acr_resource_group # Same RG as bootstrap resources
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}"
  location = var.location

  tags = var.tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  storage_account_name = "dmst${var.project_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location

  tags = var.tags
}

# Document Intelligence Module
module "document_intelligence" {
  source = "./modules/document-intelligence"

  name                = "doc-intel-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  tags = var.tags
}

# Function App Module (Blob Trigger for Document Processing)
module "function_app" {
  source = "./modules/function-app"

  function_app_name     = "func-${var.project_name}"
  service_plan_name     = "plan-${var.project_name}"
  function_storage_name = "stfunc${var.project_name}"
  app_insights_name     = "appi-${var.project_name}"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  # Data storage configuration
  data_storage_connection_string = module.storage.primary_connection_string
  data_storage_account_id        = module.storage.storage_account_id

  # Document Intelligence configuration
  doc_intelligence_endpoint = module.document_intelligence.endpoint
  doc_intelligence_key      = module.document_intelligence.primary_access_key
  doc_intelligence_id       = module.document_intelligence.id

  # Container names
  input_container_name  = module.storage.claims_container_name
  output_container_name = module.storage.processed_container_name

  tags = var.tags

  depends_on = [
    module.storage,
    module.document_intelligence
  ]
}


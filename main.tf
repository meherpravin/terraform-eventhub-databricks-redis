terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.61.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure.subscription_id
  tenant_id       = var.azure.tenant_id
  features {}
}

provider "tls" {}

provider "random" {}

data "azurerm_client_config" "current" {}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">4.53.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">3.6.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}
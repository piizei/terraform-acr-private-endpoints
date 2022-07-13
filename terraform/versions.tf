terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.8.0"
    }
    namep = {
      source  = "jason-johnson/namep"
      version = ">=1.0.5"
    }
    azapi = {
      source  = "Azure/azapi"
    }
  }
}

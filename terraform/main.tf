data "namep_azure_name" "hub" {
  name = "hub"
  location = var.location_hub
  type = "azurerm_resource_group"
}
#Change once namep is updated with sweden-central (now the name is wrong :( 
data "namep_azure_name" "spoke1" {
  name = "spoke1"
  #location = var.location_spoke1
  type = "azurerm_resource_group"
}
data "namep_azure_name" "spoke2" {
  name = "spoke2"
  location = var.location_spoke2
  type = "azurerm_resource_group"
}
resource "azurerm_resource_group" "hub" {
  name     = data.namep_azure_name.hub.result
  location = var.location_hub
  tags     = local.common_tags
}
resource "azurerm_resource_group" "spoke1" {
  name     = data.namep_azure_name.spoke1.result
  location = var.location_spoke1
  tags     = local.common_tags
}
resource "azurerm_resource_group" "spoke2" {
  name     = data.namep_azure_name.spoke2.result
  location = var.location_spoke2
  tags     = local.common_tags
}

locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    version     = var.release_version
  }
}

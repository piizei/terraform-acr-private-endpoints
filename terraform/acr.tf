data "namep_azure_name" "acr" {
  name = "xyzdfd"
  type = "azurerm_container_registry"
}

resource "random_pet" "acr" {
  separator = ""
  keepers = {
    # Generate a new pet name for each env
    env = var.environment
    
  }
}

resource "azurerm_container_registry" "acr" {
  name                          = data.namep_azure_name.acr.result
  resource_group_name           = azurerm_resource_group.spoke1.name
  location                      = azurerm_resource_group.spoke1.location
  tags                          = local.common_tags
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  georeplications {
    location                = var.location_spoke2
    zone_redundancy_enabled = true
    tags                    = local.common_tags
  }
}

output "registry_name" {
  value     = data.namep_azure_name.acr.result
  sensitive = false
}
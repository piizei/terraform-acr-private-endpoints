resource "azurerm_virtual_network" "spoke2" {
  name                = "spoke2"
  address_space       = ["10.11.0.0/16"]
  resource_group_name = azurerm_resource_group.spoke2.name
  location            = azurerm_resource_group.spoke2.location
  tags                = local.common_tags
}

resource "azurerm_subnet" "spoke2" {
  name                                           = "default"
  resource_group_name                            = azurerm_resource_group.spoke2.name
  virtual_network_name                           = azurerm_virtual_network.spoke2.name
  address_prefixes                               = ["10.11.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke2" {
  name                  = "spoke2"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.spoke2.id
  tags                  = local.common_tags
}


resource "azurerm_virtual_network_peering" "spoke2-hub" {
  name                         = "spoke2-hub"
  resource_group_name          = azurerm_resource_group.spoke2.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}



resource "azurerm_private_endpoint" "acr-spoke2" {
  name                = "spoke2-acr"
  location            = azurerm_resource_group.spoke2.location
  resource_group_name = azurerm_resource_group.spoke2.name
  subnet_id           = azurerm_subnet.spoke2.id
  tags                = local.common_tags
  private_service_connection {
    name                           = "spoke2-acr"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

}

resource "azurerm_network_security_group" "spoke2-default" {
  name                = "spoke2-vnet-default-nsg"
  location            = azurerm_resource_group.spoke2.location
  resource_group_name = azurerm_resource_group.spoke2.name

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-a-spoke2" {
  subnet_id                 = azurerm_subnet.spoke2.id
  network_security_group_id = azurerm_network_security_group.spoke2-default.id
}
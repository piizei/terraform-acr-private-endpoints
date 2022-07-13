resource "azurerm_virtual_network" "spoke1" {
  name                = "spoke1"
  address_space       = ["10.10.0.0/16"]
  resource_group_name = azurerm_resource_group.spoke1.name
  location            = azurerm_resource_group.spoke1.location
  tags                = local.common_tags
}

resource "azurerm_subnet" "spoke1" {
  name                                           = "default"
  resource_group_name                            = azurerm_resource_group.spoke1.name
  virtual_network_name                           = azurerm_virtual_network.spoke1.name
  address_prefixes                               = ["10.10.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}


resource "azurerm_private_dns_zone_virtual_network_link" "spoke1" {
  name                  = "spoke1"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.spoke1.id
  tags                  = local.common_tags
}

resource "azurerm_virtual_network_peering" "spoke1-hub" {
  name                         = "spoke1-hub"
  resource_group_name          = azurerm_resource_group.spoke1.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_private_endpoint" "acr" {
  name                = "spoke1-acr"
  location            = azurerm_resource_group.spoke1.location
  resource_group_name = azurerm_resource_group.spoke1.name
  subnet_id           = azurerm_subnet.spoke1.id
  tags                = local.common_tags


  private_service_connection {
    name                           = "spoke1-acr"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

}


resource "azurerm_network_security_group" "spoke1-default" {
  name                = "spoke1-vnet-default-nsg"
  location            = azurerm_resource_group.spoke1.location
  resource_group_name = azurerm_resource_group.spoke1.name


  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-a-spoke1" {
  subnet_id                 = azurerm_subnet.spoke1.id
  network_security_group_id = azurerm_network_security_group.spoke1-default.id
}
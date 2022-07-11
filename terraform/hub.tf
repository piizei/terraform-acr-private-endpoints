# Todo: hub_vnet to hub

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub"
  address_space       = ["10.12.0.0/16"]
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "hub"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_subnet" "hub_default" {
  name                                           = "default"
  resource_group_name                            = azurerm_resource_group.hub.name
  virtual_network_name                           = azurerm_virtual_network.hub_vnet.name
  address_prefixes                               = ["10.12.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}
resource "azurerm_subnet" "hub_gw" {
  name                                           = "GatewaySubnet"
  resource_group_name                            = azurerm_resource_group.hub.name
  virtual_network_name                           = azurerm_virtual_network.hub_vnet.name
  address_prefixes                               = ["10.12.10.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "hub_fw" {
  name                                           = "AzureFirewallSubnet"
  resource_group_name                            = azurerm_resource_group.hub.name
  virtual_network_name                           = azurerm_virtual_network.hub_vnet.name
  address_prefixes                               = ["10.12.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "hub_bastion" {
  name                                           = "AzureBastionSubnet"
  resource_group_name                            = azurerm_resource_group.hub.name
  virtual_network_name                           = azurerm_virtual_network.hub_vnet.name
  address_prefixes                               = ["10.12.3.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_public_ip" "public_ip_gw" {
  name                = "public-ip-gw"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "public_ip_fw" {
  name                = "public-ip-fw"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "hub-default" {
  name                = "hub-vnet-default-nsg"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 650
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 651
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 655
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-a-hub" {
  subnet_id                 = azurerm_subnet.hub_default.id
  network_security_group_id = azurerm_network_security_group.hub-default.id
}

resource "azurerm_firewall" "firewall" {
  name                = "hub-fw"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.p1.id
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_fw.id
    public_ip_address_id = azurerm_public_ip.public_ip_fw.id
  }
  tags = local.common_tags

}

resource "azurerm_firewall_policy" "p1" {
  name                = "hub-fw-policy"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
}


resource "azurerm_virtual_network_gateway" "vnet_gateway" {
  name                = "hub-vnet-gateway"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type = "Vpn"
  sku  = "VpnGw2"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.public_ip_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gw.id
  }
  tags = local.common_tags
}

resource "azurerm_network_security_group" "hub_bastion" {
  name                = "hub-vnet-bastion-nsg"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 443
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 650
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 651
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 655
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSshOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowVnetOutBound"
    priority                   = 650
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 651
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 660
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-a-bastion-hub" {
  subnet_id                 = azurerm_subnet.hub_bastion.id
  network_security_group_id = azurerm_network_security_group.hub_bastion.id
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags
}

resource "azurerm_virtual_network_peering" "hub-spoke1" {
  name                         = "hub-spoke1"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub-spoke2" {
  name                         = "hub-spoke2"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

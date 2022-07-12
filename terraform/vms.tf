resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


#Spoke 1
resource "azurerm_network_interface" "vm1" {
  name                = "vm1nic"
  resource_group_name = azurerm_resource_group.spoke1.name
  location            = azurerm_resource_group.spoke1.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke1test" {
  name                            = "spoke1-test-vm"
  resource_group_name             = azurerm_resource_group.spoke1.name
  location                        = azurerm_resource_group.spoke1.location
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  admin_password                  = random_password.password.result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm1.id]
  tags                            = local.common_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm1" {
  virtual_machine_id = azurerm_linux_virtual_machine.spoke1test.id
  location           = azurerm_resource_group.spoke1.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "Central Europe Standard Time"

  notification_settings {
    enabled = false
  }

}
#Spoke 2
resource "azurerm_network_interface" "vm2" {
  name                = "vm2nic"
  resource_group_name = azurerm_resource_group.spoke2.name
  location            = azurerm_resource_group.spoke2.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke2test" {
  name                            = "spoke2-test-vm"
  resource_group_name             = azurerm_resource_group.spoke2.name
  location                        = azurerm_resource_group.spoke2.location
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  admin_password                  = random_password.password.result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm2.id]
  tags                            = local.common_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm2" {
  virtual_machine_id = azurerm_linux_virtual_machine.spoke2test.id
  location           = azurerm_resource_group.spoke2.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "Central Europe Standard Time"

  notification_settings {
    enabled = false
  }

}

output "password" {
  value     = random_password.password.result
  sensitive = true
}

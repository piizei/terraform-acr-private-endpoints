locals {
  dns_details = [data.namep_azure_name.acr.result, "${data.namep_azure_name.acr.result}.${var.location_acr}.data", "${data.namep_azure_name.acr.result}.${var.location_acr_replica}.data"]
}

# This is a bit of hack as all of the dns information could be fetched dynamically from the private-endpoint-config, but that would require the state to exists first.
# If you are using a layered configuration (multiple states), you can get rid of the variables.


resource "azurerm_private_dns_a_record" "acr" {
  for_each            = toset(local.dns_details)
  name                = each.key
  zone_name           = azurerm_private_dns_zone.acr.name
  resource_group_name = azurerm_resource_group.hub.name
  ttl                 = 10
  records             = concat(azurerm_private_endpoint.acr.custom_dns_configs[index(azurerm_private_endpoint.acr.custom_dns_configs.*.fqdn, "${each.key}.azurecr.io")].ip_addresses, azurerm_private_endpoint.acr-spoke2.custom_dns_configs[index(azurerm_private_endpoint.acr.custom_dns_configs.*.fqdn, "${each.key}.azurecr.io")].ip_addresses)
}

provider "namep" {
  default_location = var.location_hub
  extra_tokens = {
    env = var.environment
  }
  # Using the default formatting #{SLUG}#{SHORT_LOC}#{NAME} for most resources, but its confusing for RGs
  resource_formats = {
    azurerm_resource_group = "#{SLUG}-#{SHORT_LOC}-#{ENV}-#{NAME}"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {

}
data "azurerm_subscription" "current" {}

resource "azurerm_network_security_group" "existing" {
  name                = "nsg-existing"
  location            = var.location
  resource_group_name = var.resource_group_name
}

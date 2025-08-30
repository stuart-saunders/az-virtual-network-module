resource "azurerm_route_table" "existing" {
  name                = "rt-existing"
  location            = var.location
  resource_group_name = var.resource_group_name
}

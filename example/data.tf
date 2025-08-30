data "azurerm_subscription" "this" {}

data "azurerm_network_security_group" "existing" {
  for_each = {
    for key, subnet in local.subnets : key => subnet
    if subnet.existing_network_security_group != null
  }

  name                = each.value.existing_network_security_group.name
  resource_group_name = try(each.value.resource_group_name, null) != null ? each.value.resource_group_name : var.resource_group_name

  depends_on = [azurerm_network_security_group.existing]
}

data "azurerm_route_table" "existing" {
  for_each = {
    for key, subnet in local.subnets : key => subnet
    if subnet.existing_route_table != null
  }

  name                = each.value.existing_route_table.name
  resource_group_name = try(each.value.resource_group_name, null) != null ? each.value.resource_group_name : var.resource_group_name

  depends_on = [
    azurerm_route_table.existing
  ]

}

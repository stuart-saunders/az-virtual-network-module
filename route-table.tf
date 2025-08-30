resource "azurerm_route_table" "this" {
  for_each = (
    {
      for subnet in local.subnets : "${subnet.name}_${subnet.route_table.name}" => subnet.route_table
      if subnet.route_table != null
    }
  )

  name                          = each.value.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled

  tags = var.tags
}

resource "azurerm_route" "this" {
  for_each = local.routes

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this["${each.value.subnet_name}_${each.value.route_table_name}"].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = {
    for subnet in local.subnets : "${subnet.name}_${subnet.route_table.name}" => subnet
    if subnet.route_table != null
  }

  route_table_id = azurerm_route_table.this[each.key].id
  subnet_id = azurerm_subnet.this[each.value.name].id
}

resource "azurerm_subnet_route_table_association" "existing_route_table" {
  for_each = {
    for key, subnet in local.subnets : key => subnet
    if subnet.route_table_id != null
  }

  route_table_id = each.value.route_table_id
  subnet_id = azurerm_subnet.this[each.value.name].id
}

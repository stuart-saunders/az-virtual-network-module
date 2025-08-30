resource "azurerm_network_security_group" "this" {
  for_each = (
    {
      for subnet in local.subnets : "${subnet.name}_${subnet.network_security_group.name}" => subnet.network_security_group
      if subnet.network_security_group != null
    }
  )

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.nsg_rules

  network_security_group_name = azurerm_network_security_group.this["${each.value.subnet_name}_${each.value.nsg_name}"].name
  resource_group_name         = var.resource_group_name

  name                         = each.value.name
  access                       = each.value.access
  direction                    = each.value.direction
  priority                     = each.value.priority
  protocol                     = each.value.protocol
  source_address_prefix        = each.value.source_address_prefix != null ? each.value.source_address_prefix : null
  source_address_prefixes      = each.value.source_address_prefixes != null ? each.value.source_address_prefixes : null
  source_port_range            = each.value.source_port_range != null ? each.value.source_port_range : null
  source_port_ranges           = each.value.source_port_ranges != null ? each.value.source_port_ranges : null
  destination_address_prefix   = each.value.destination_address_prefix != null ? each.value.destination_address_prefix : null
  destination_address_prefixes = each.value.destination_address_prefixes != null ? each.value.destination_address_prefixes : null
  destination_port_range       = each.value.destination_port_range != null ? each.value.destination_port_range : null
  destination_port_ranges      = each.value.destination_port_ranges != null ? each.value.destination_port_ranges : null
}

# Provision NSG associations for the NSGs created in this configuration
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    # create when an NSG is specified for a subnet
    for subnet in local.subnets : "${subnet.name}_${subnet.network_security_group.name}" => subnet
    if try(subnet.network_security_group, null) != null
  }

  network_security_group_id = azurerm_network_security_group.this[each.key].id
  subnet_id                 = azurerm_subnet.this[each.value.name].id
}

# Provision associations between subnets and pre-existing NSGs, where specified
resource "azurerm_subnet_network_security_group_association" "existing_nsg" {
  for_each = {
    # create when an existing NSG's Id is supplied for a subnet
    for key, subnet in local.subnets : key => subnet
    if subnet.network_security_group_id != null
  }

  network_security_group_id = each.value.network_security_group_id
  subnet_id                 = azurerm_subnet.this[each.key].id
}

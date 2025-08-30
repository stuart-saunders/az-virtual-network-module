locals {
  subscription_id = var.subscription_id != null ? var.subscription_id : data.azurerm_subscription.this.id

  # convert the subnet list to a map of subnet objects
  subnets = { for subnet in var.subnets :
    subnet.name => subnet
  }

  # convert the rules list to a map of rule objects
  nsg_rules = merge([for subnet_key, subnet in local.subnets :
    {
      for rule in try(subnet.network_security_group.rules, []) :
      "${subnet.network_security_group.name}_${rule.priority}-${rule.name}" => {
        subnet_name           = subnet.name
        nsg_name              = subnet.network_security_group.name
        name                  = rule.name
        priority              = rule.priority
        direction             = rule.direction
        access                = rule.access
        protocol              = rule.protocol
        source_address_prefix = try(rule.source_address_prefix, null) != null ? rule.source_address_prefix : null
        # If no source address prefix/prefixes are provided, default to using the subnet address
        source_address_prefixes    = try(rule.source_address_prefixes, null) != null ? rule.source_address_prefixes : (try(rule.source_address_prefix, null) != null ? null : subnet.address_prefixes)
        source_port_range          = try(rule.source_port_range, null) != null ? rule.source_port_range : null
        source_port_ranges         = try(rule.source_port_ranges, null) != null ? rule.source_port_ranges : null
        destination_address_prefix = try(rule.destination_address_prefix, null) != null ? rule.destination_address_prefix : null
        # If no destination address prefix/prefixes are provided, default to using the subnet address
        destination_address_prefixes = try(rule.destination_address_prefixes, null) != null ? rule.destination_address_prefixes : (try(rule.destination_address_prefix, null) != null ? null : subnet.address_prefixes)
        destination_port_range       = try(rule.destination_port_range, null) != null ? rule.destination_port_range : null
        destination_port_ranges      = try(rule.destination_port_ranges, null) != null ? rule.destination_port_ranges : null
      }
    }
  ]...)

  # create a single list of peering objects
  peerings_list = flatten([for peering in var.peerings :
    # for each peering specified, create lists of object pairs representing both sides of the peering
    [
      # create an object representing the peering from the local network to the remote (i.e. source is local)
      {
        key                                        = "${azurerm_virtual_network.this.name}_to_${peering.remote_virtual_network.name}"
        subscription_id                            = local.subscription_id
        name                                       = peering.name != null ? peering.name : peering.remote_virtual_network.name
        source_virtual_network_resource_group_name = var.resource_group_name
        source_virtual_network_name                = azurerm_virtual_network.this.name
        remote_virtual_network_id = (
          try(peering.remote_virtual_network.id, null) != null ? peering.remote_virtual_network_id : (
            "/subscriptions/${local.subscription_id}/resourceGroups/${try(peering.remote_virtual_network.resource_group_name, null) != null ?
              peering.remote_virtual_network.resource_group_name :
            var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${peering.remote_virtual_network.name}"
          )
        )
        allow_forwarded_traffic      = peering.source_to_remote_config.allow_forwarded_traffic
        allow_gateway_transit        = peering.source_to_remote_config.allow_gateway_transit
        allow_virtual_network_access = peering.source_to_remote_config.allow_virtual_network_access
        use_remote_gateways          = peering.source_to_remote_config.use_remote_gateways
      },
      # create an object representing the peering from the remote to the local (i.e. source is remote, and the remote network id is the local network)
      {
        key                                        = "${peering.remote_virtual_network.name}_to_${azurerm_virtual_network.this.name}"
        subscription_id                            = local.subscription_id
        name                                       = azurerm_virtual_network.this.name
        source_virtual_network_resource_group_name = peering.remote_virtual_network.resource_group_name != null ? peering.remote_virtual_network.resource_group_name : var.resource_group_name
        source_virtual_network_name                = peering.remote_virtual_network.name
        remote_virtual_network_id                  = azurerm_virtual_network.this.id
        allow_forwarded_traffic                    = peering.remote_to_source_config.allow_forwarded_traffic
        allow_gateway_transit                      = peering.remote_to_source_config.allow_gateway_transit
        allow_virtual_network_access               = peering.remote_to_source_config.allow_virtual_network_access
        use_remote_gateways                        = peering.remote_to_source_config.use_remote_gateways
      }
    ]
  ])

  # convert the peering list to a map of peering objects
  peerings = { for peering in local.peerings_list :
    peering.key => peering
  }

  # convert the route list to a map of route objects
  routes = merge([for subnet_key, subnet in local.subnets :
    {
      for route in try(subnet.route_table.routes, []) :
      "${subnet.route_table.name}_${route.name}" => {
        subnet_name            = subnet.name
        route_table_name       = subnet.route_table.name
        name                   = route.name
        address_prefix         = route.address_prefix
        next_hop_type          = route.next_hop_type
        next_hop_in_ip_address = route.next_hop_in_ip_address
      }
    }
  ]...)
}

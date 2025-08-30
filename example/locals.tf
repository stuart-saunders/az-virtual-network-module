locals {
  subscription_id = var.subscription_id != null ? var.subscription_id : data.azurerm_subscription.this.id

  vnets = { for vnet in var.vnets :
    # replace the vnet's subnets list with one containing subnet objects which include the Ids of any associated, existing resources
    vnet.name => merge(
      vnet,
      {
        # replace the subnet object with one containing the Ids of any associated, existing resources
        subnets = [for subnet in vnet.subnets : merge(
          subnet,
          subnet.existing_network_security_group != null ? {
            # network_security_group_id = data.azurerm_network_security_group.existing["${vnet.name}_${subnet.name}"].id
            network_security_group_id = "/subscriptions/${local.subscription_id}/resourceGroups/${subnet.existing_network_security_group.resource_group_name != null ? subnet.existing_network_security_group.resource_group_name : var.resource_group_name}/providers/Microsoft.Network/networkSecurityGroups/${subnet.existing_network_security_group.name}"
          } : {},
          # if an existing NSG has been specified for a subnet, construct and append its Id
          subnet.existing_route_table != null ? {
            # route_table_id = data.azurerm_route_table.existing["${vnet.name}_${subnet.name}"].id
            route_table_id = "/subscriptions/${local.subscription_id}/resourceGroups/${subnet.existing_network_security_group.resource_group_name != null ? subnet.existing_network_security_group.resource_group_name : var.resource_group_name}/providers/Microsoft.Network/routeTables/${subnet.existing_route_table.name}"
          } : {}
        )]
      }
    )
  }

  subnets = merge([for vnet in var.vnets :
    {
      for subnet in vnet.subnets :
      "${vnet.name}_${subnet.name}" => merge(
        subnet,
        { vnet_name = vnet.name }
      )
    }
  ]...)
}

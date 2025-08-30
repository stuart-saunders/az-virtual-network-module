resource "azurerm_virtual_network_peering" "this" {
  for_each = local.peerings

  name                         = each.key
  resource_group_name          = var.resource_group_name
  virtual_network_name         = each.value.source_virtual_network_name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  allow_virtual_network_access = each.value.allow_virtual_network_access
  use_remote_gateways          = each.value.use_remote_gateways

  depends_on = [
    azurerm_virtual_network.this
  ]
}

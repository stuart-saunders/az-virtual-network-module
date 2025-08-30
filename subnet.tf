resource "azurerm_subnet" "this" {
  for_each = local.subnets

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  default_outbound_access_enabled = each.value.default_outbound_access_enabled

  dynamic "delegation" {
    for_each = each.value.delegations

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  dynamic "ip_address_pool" {
    for_each = each.value.ip_address_pool != null ? { "instance" = each.value.ip_address_pool } : {}

    content {
      id                     = ip_address_pool.value.id
      number_of_ip_addresses = ip_address_pool.value.number_of_ip_addresses
    }
  }

  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  service_endpoints           = each.value.service_endpoints
  service_endpoint_policy_ids = each.value.service_endpoint_policy_ids
}

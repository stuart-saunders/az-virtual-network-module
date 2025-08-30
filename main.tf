resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? { "instance" = var.ddos_protection_plan } : {}

    content {
      enable = try(each.value.enable, null)
      id     = try(each.value.id, null)
    }
  }

  edge_zone = var.edge_zone

  encryption {
    enforcement = var.encryption.enforcement
  }

  flow_timeout_in_minutes = var.flow_timeout_in_minutes

  dynamic "ip_address_pool" {
    for_each = var.ip_address_pool != null ? { "instance" = var.ip_address_pool } : {}

    content {
      id                     = each.value.id
      number_of_ip_addresses = each.value.number_of_ip_addresses
    }
  }

  private_endpoint_vnet_policies = var.private_endpoint_vnet_policies

  tags = var.tags
}

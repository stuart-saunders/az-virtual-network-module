resource "azurerm_virtual_network_dns_servers" "this" {
  for_each = length(var.dns_servers) > 0 ? { "instance" = var.dns_servers } : {}

  virtual_network_id = azurerm_virtual_network.this.id
  dns_servers        = var.dns_servers
}

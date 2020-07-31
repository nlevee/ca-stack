output "subnet_ids" {
  value = azurerm_subnet.default.*.id
}

output "network_id" {
  value = azurerm_virtual_network.network.id
}

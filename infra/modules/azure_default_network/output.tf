output "subnet_ids" {
  description = "Id for each subnet created"
  value       = azurerm_subnet.default.*.id
}

output "subnet_address_ranges" {
  description = "Address range computed for each subnet created"
  value       = azurerm_subnet.default[*].address_prefixes[0]
}

output "network_id" {
  description = "Created etwork Id"
  value       = azurerm_virtual_network.network.id
}

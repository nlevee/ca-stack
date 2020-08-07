output "resource_group_name" {
  description = "Resource group in azure"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location where the resource group has been created"
  value       = azurerm_resource_group.main.location
}

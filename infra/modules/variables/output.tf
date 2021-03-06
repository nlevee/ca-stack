output "azure_location" {
  description = "Location (West Europe, ...) in azure"
  value       = lookup(local.workspace_to_azure_location, var.workspace, "")
}

output "azure_resource_group" {
  description = "Resource group in azure"
  value       = "${lookup(local.workspace_to_azure_resource_group, var.workspace, "")}${var.name_suffix}"
}

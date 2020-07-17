output "azure_location" {
  value = lookup(var.workspace_to_azure_location, var.workspace, "")
}

output "azure_resource_group" {
  value = lookup(var.workspace_to_azure_resource_group, var.workspace, "")
}

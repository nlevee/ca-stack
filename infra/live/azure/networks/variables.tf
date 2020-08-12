variable "workspace" {
  description = "Workspace name to get vars"
  default     = "azure-staging"
}

variable "name_suffix" {
  description = "Suffix to add to all name outputs"
  default     = ""
}

module "variables" {
  source = "../../../modules/variables"

  workspace   = var.workspace
  name_suffix = var.name_suffix
}

variable "resource_group_name" {
  description = "Resource group in azure, must already exist"
  type        = string
  default     = ""
}

# fetch resource group data
data "azurerm_resource_group" "default" {
  name = local.resource_group_name
}

locals {
  resource_group_name     = var.resource_group_name != "" ? var.resource_group_name : module.variables.azure_resource_group
  resource_group_location = data.azurerm_resource_group.default.location
}

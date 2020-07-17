variable "workspace_to_azure_resource_group" {
  type = map

  default = {
    "azure-staging" = "ca-stack"
  }
}

variable "workspace_to_azure_location" {
  type = map

  default = {
    "azure-staging" = "West Europe"
  }
}

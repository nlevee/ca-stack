locals {
  workspace_to_azure_resource_group = {
    "azure-staging" = "ca-stack"
    "azure-testing" = "testing-ca-stack"
  }
  workspace_to_azure_location = {
    "azure-staging" = "westeurope"
    "azure-testing" = "francecentral"
  }
}


data "azurerm_client_config" "current" {}

data "terraform_remote_state" "networks" {
  backend = "local"

  config = {
    path = "${path.module}/../networks/terraform.tfstate"
  }
}

resource "azurerm_key_vault" "vm-vault" {
  name                        = "${module.variables.azure_resource_group}-vm-vault"
  location                    = module.variables.azure_location
  resource_group_name         = module.variables.azure_resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get", "list",
    ]

    secret_permissions = [
      "get", "list",
    ]

    storage_permissions = [
      "get", "list",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    # assign access from subnet
    virtual_network_subnet_ids = [
      data.terraform_remote_state.networks.outputs.from_vault_network_id,
      data.terraform_remote_state.networks.outputs.to_vault_network_id
    ]
  }
}


# fetch azure client data
data "azurerm_client_config" "current" {}

# fetch resource group data
data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

# generate unique vault
module "azure_naming" {
  source = "Azure/naming/azurerm"
  suffix = [var.vault_name, var.resource_group_name]
}

# create key vault
resource "azurerm_key_vault" "default" {
  name                     = module.azure_naming.key_vault.name_unique
  location                 = data.azurerm_resource_group.default.location
  resource_group_name      = var.resource_group_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled      = true
  purge_protection_enabled = false

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    ip_rules = var.ip_rules

    # assign access from subnet
    virtual_network_subnet_ids = var.subnet_ids
  }
}

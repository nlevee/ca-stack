
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "default" {
  name                     = var.vault_name
  location                 = var.location
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

# fetch image id
data "azurerm_image" "web_proxy" {
  name                = var.image_name
  resource_group_name = module.variables.azure_resource_group
}

# create web_proxy vm
resource "azurerm_linux_virtual_machine" "web_proxy" {
  name                = "WebProxyVm"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.web.id,
    azurerm_network_interface.issuer.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_id = data.azurerm_image.web_proxy.id
}

# add startup script
resource "azurerm_virtual_machine_extension" "provision" {
  name                 = "provision"
  virtual_machine_id   = azurerm_linux_virtual_machine.web_proxy.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  depends_on = [
    azurerm_key_vault_access_policy.vm_vault,
    azurerm_key_vault_access_policy.issuer_vault,
    azurerm_key_vault_access_policy.cfssl_vault,
  ]

  protected_settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("${path.module}/scripts/provision-proxy.sh.tmpl", {
  issuer_fqdn      = data.terraform_remote_state.issuer.outputs.issuer_fqdn
  vm_vault_uri     = data.terraform_remote_state.vault.outputs.vm_vault_uri
  issuer_vault_uri = data.terraform_remote_state.vault.outputs.issuer_vault_uri
  cfssl_vault_uri  = data.terraform_remote_state.vault.outputs.cfssl_vault_uri
}))}"
    }
SETTINGS
}

# access policy to access to vault
resource "azurerm_key_vault_access_policy" "vm_vault" {
  key_vault_id = data.terraform_remote_state.vault.outputs.vm_vault_id

  tenant_id = azurerm_linux_virtual_machine.web_proxy.identity[0].tenant_id
  object_id = azurerm_linux_virtual_machine.web_proxy.identity[0].principal_id

  secret_permissions = [
    "get"
  ]
}
resource "azurerm_key_vault_access_policy" "issuer_vault" {
  key_vault_id = data.terraform_remote_state.vault.outputs.issuer_vault_id

  tenant_id = azurerm_linux_virtual_machine.web_proxy.identity[0].tenant_id
  object_id = azurerm_linux_virtual_machine.web_proxy.identity[0].principal_id

  certificate_permissions = [
    "get"
  ]
}

resource "azurerm_key_vault_access_policy" "cfssl_vault" {
  key_vault_id = data.terraform_remote_state.vault.outputs.cfssl_vault_id

  tenant_id = azurerm_linux_virtual_machine.web_proxy.identity[0].tenant_id
  object_id = azurerm_linux_virtual_machine.web_proxy.identity[0].principal_id

  secret_permissions = [
    "get"
  ]
}

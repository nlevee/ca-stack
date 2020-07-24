# fetch image id
data "azurerm_image" "web-proxy" {
  name                = var.image_name
  resource_group_name = module.variables.azure_resource_group
}

# create web-proxy vm
resource "azurerm_linux_virtual_machine" "web-proxy" {
  name                = "web-proxy-vm"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.internal.id,
    azurerm_network_interface.ca-issuer.id,
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

  boot_diagnostics {
    storage_account_uri = "https://castackbootdiag.blob.core.windows.net/"
  }

  source_image_id = data.azurerm_image.web-proxy.id
}

# add startup script
resource "azurerm_virtual_machine_extension" "provision" {
  name                 = "provision-proxy"
  virtual_machine_id   = azurerm_linux_virtual_machine.web-proxy.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
    {
        "script": "${filebase64("${path.module}/scripts/provision-proxy.sh")}"
    }
SETTINGS
}

# access policy to access to vault
resource "azurerm_key_vault_access_policy" "web-proxy-policy-vm-vault" {
  key_vault_id = data.terraform_remote_state.vault.outputs.vm_vault_id

  tenant_id = azurerm_linux_virtual_machine.web-proxy.identity[0].tenant_id
  object_id = azurerm_linux_virtual_machine.web-proxy.identity[0].principal_id

  secret_permissions = [
    "get"
  ]
}
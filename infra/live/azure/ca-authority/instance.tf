# fetch image id
data "azurerm_image" "ca-authority" {
  name                = var.image_name
  resource_group_name = module.variables.azure_resource_group
}

# create ca-authority vm
resource "azurerm_linux_virtual_machine" "ca-authority" {
  name                = "ca-authority-vm"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.ca-authority.id,
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

  source_image_id = data.azurerm_image.ca-authority.id
}

# add startup script
resource "azurerm_virtual_machine_extension" "ca-authority-script" {
  name                 = "generate-certificate"
  virtual_machine_id   = azurerm_linux_virtual_machine.ca-authority.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
    {
        "script": "${filebase64("${path.module}/scripts/provision-authority.sh")}"
    }
SETTINGS
}

# access policy to access to vault
resource "azurerm_key_vault_access_policy" "ca-authority-ap-vault" {
  key_vault_id = data.terraform_remote_state.vault.outputs.vault_id

  tenant_id = azurerm_linux_virtual_machine.ca-authority.identity[0].tenant_id
  object_id = azurerm_linux_virtual_machine.ca-authority.identity[0].principal_id

  secret_permissions = [
    "get", "set"
  ]

  certificate_permissions = [
    "import", "get"
  ]
}

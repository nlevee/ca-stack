# create ca-issuer network interface
resource "azurerm_network_interface" "ca-issuer" {
  name                = "ca-issuer-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.to_vault_network_id
    private_ip_address_allocation = "Dynamic"
  }
}

# create ca-issuer vm
resource "azurerm_linux_virtual_machine" "ca-issuer" {
  name                = "ca-issuer-vm"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
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

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10-backports"
    version   = "latest"
  }
}

# add startup script
resource "azurerm_virtual_machine_extension" "ca-issuer-script" {
  name                 = "startup-issuer"
  virtual_machine_id   = azurerm_linux_virtual_machine.ca-issuer.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
    {
        "script": "${filebase64("${path.module}/scripts/startup-issuer.sh")}"
    }
SETTINGS
}

# access policy to access to vault
resource "azurerm_key_vault_access_policy" "ca-issuer-ap-vault" {
  key_vault_id = data.terraform_remote_state.vault.outputs.vault_id

  tenant_id = azurerm_linux_virtual_machine.ca-issuer.identity[0].tenant_id
  object_id = azurerm_linux_virtual_machine.ca-issuer.identity[0].principal_id

  secret_permissions = [
    "get"
  ]

  certificate_permissions = [
    "get"
  ]
}

variable "resource_group_name" {
  description = "Resource group in azure"
  type        = string
}

variable "vault_name" {
  description = "Vault basename (a suffix is added to make it unique)"
  type        = string
}

variable "ip_rules" {
  default = []
}

variable "subnet_ids" {
  default = []
}

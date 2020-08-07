variable "location" {
  description = "Location (West Europe, ...) in azure"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in azure"
  type        = string
}

variable "vault_name" {
  description = "Vault name (must be unique)"
  type        = string
}

variable "ip_rules" {
  default = []
}

variable "subnet_ids" {
  default = []
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vault_name" {
  type = string
}

variable "ip_rules" {
  default = []
}

variable "subnet_ids" {
  default = []
}

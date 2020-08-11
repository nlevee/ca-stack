variable "network_name" {
  type = string
}

variable "address_range" {
  type = string
}

variable "nsg_id" {
  default = ""
}

variable "subnet_names" {
  description = "Subnet list names to create, each subnet's address range is compute from 'address_range' variable"
  default     = ["default"]
  type        = list(string)
}

variable "service_endpoints" {
  description = "Endpoints list to connect to this network"
  default     = []
  type        = list(string)
}

variable "location" {
  description = "Location (West Europe, ...) in azure"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in azure"
  type        = string
}

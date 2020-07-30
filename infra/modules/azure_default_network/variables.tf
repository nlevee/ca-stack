variable "network_name" {
  type = string
}

variable "subnet_name" {
  type    = string
  default = "default"
}

variable "address_range" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_endpoints" {
  default = []
}

variable "nsg_id" {
  type = string
}

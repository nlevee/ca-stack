output "proxy_firewall_name" {
  value = module.firewall_proxy.fw_name
}

output "proxy_firewall_public_ip" {
  value = module.firewall_proxy.fw_public_ip
}

output "ca_firewall_name" {
  value = module.firewall_ca.fw_name
}

output "ca_firewall_public_ip" {
  value = module.firewall_ca.fw_public_ip
}
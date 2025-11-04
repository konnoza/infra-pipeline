output "vm_public_ip" {
  description = "The public IP address of the Windows VM."
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "vm_private_ip" {
  description = "The private IP address of the Windows VM."
  value       = azurerm_network_interface.vm_nic.ip_configuration[0].private_ip_address
}

output "admin_password" {
  description = "The auto-generated administrator password for the Windows VM."
  value       = random_password.admin_password.result
  sensitive   = true # IMPORTANT: This hides the output in plan/apply logs
}
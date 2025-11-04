output "public_ssh_key" {
  description = "A generated ssh public key."
  value       = var.public_ssh_key != "" ? "" : tls_private_key.ssh.public_key_openssh
}
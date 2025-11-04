resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  count    = var.public_ssh_key == "" && !var.key_vault_storage_enabled ? 1 : 0
  content  = tls_private_key.ssh.private_key_pem
  filename = var.hostname == "" ? "./private_ssh.key" : "./${var.hostname}.key"
}

resource "local_file" "pub_key" {
  count    = var.public_ssh_key == "" && !var.key_vault_storage_enabled ? 1 : 0
  content  = tls_private_key.ssh.public_key_openssh
  filename = var.hostname == "" ? "./private_ssh.pub" : "./${var.hostname}.pub"
}

# Require `purge` to destroy the secret
resource "azurerm_key_vault_secret" "module-generated" {
  count = var.public_ssh_key == "" && var.key_vault_storage_enabled ? 1 : 0

  name         = var.hostname
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = var.key_vault_id
}
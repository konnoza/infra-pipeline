# 1. Generate a secure random password for the VM
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# 2a. Create a Public IP Address resource
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.vm_name}-pip-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic" # Or "Static" if preferred
  sku                 = "Basic"   # Or "Standard"
}

# 2b. Create a Network Interface (NIC) and associate the Public IP
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic-001"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id                     # The VM's Private IP comes from this subnet
    private_ip_address_allocation = "Dynamic"                         # Or "Static"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id # Associates the Public IP
  }
}

# 3. Create the Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  # Admin credentials using the generated password
  admin_username = var.admin_username
  admin_password = random_password.admin_password.result

  os_disk {
    name                 = "${var.vm_name}-osdisk-001"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }
}
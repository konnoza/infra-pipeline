variable "resource_group_name" {
  description = "The name of the Resource Group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the VM will be created."
  type        = string
}

variable "vm_name" {
  description = "The name of the Windows Virtual Machine."
  type        = string
}

variable "vm_size" {
  description = "The SKU for the Virtual Machine (e.g., Standard_B2s)."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to associate with the VM's network interface."
  type        = string
}

variable "admin_username" {
  description = "The administrator username for the Virtual Machine."
  type        = string
  default     = "azureadmin" # Example default
}

variable "source_image_reference_publisher" {
  description = "Specifies the publisher of the image used to create the virtual machines."
  type        = string
}

variable "source_image_reference_offer" {
  description = "Specifies the offer of the image used to create the virtual machines."
  type        = string
}

variable "source_image_reference_sku" {
  description = "Specifies the SKU of the image used to create the virtual machines."
  type        = string
}

variable "source_image_reference_version" {
  description = "Specifies the SKU of the image used to create the virtual machines."
  type        = string
}
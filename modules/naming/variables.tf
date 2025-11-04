variable "resource_cp" {
  description = "Name of cloud provider"
  type        = string
  default     = "az"

  validation {
    condition     = can(regex("^(az|aw|gc|hw)$", var.resource_cp))
    error_message = "The resource_cp value must be in 2 charater format as follows => az (Azure), aw (AWS), gc (GCP), hw (Huawei)."
  }
}

variable "resource_region" {
  description = "Name of Azure Regions"
  type        = string
  default     = "southeastasia"
}

variable "resource_env" {
  description = "Name of environment"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|sit|uat|stg|prd|sbx)$", var.resource_env))
    error_message = "The resource_cp value must be in 2 charater format as follows => dev, sit, stg, prd, sbx."
  }
}

variable "resource_list" {
  description = "List of resources to acquire thier names"
  type = list(object({
    resource_type  = string
    resource_name  = string
    instance_start = number
    instance_count = number
  }))
  default = [
    {
      resource_type  = "virtual_network"
      resource_name  = "demo.module"
      instance_start = 1
      instance_count = 1
    },
    {
      resource_type  = "subnet"
      resource_name  = "demo.module1"
      instance_start = 1
      instance_count = 3
    },
    {
      resource_type  = "subnet"
      resource_name  = "demo.module2"
      instance_start = 5
      instance_count = 2
    }
  ]
}
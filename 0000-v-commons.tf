variable "project_prefix" {
  description = "Prefix of the project"
  type        = string
}

variable "environment" {
  description = "Environment of the project ==> dev|sit|stg|prd|sbx"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|sit|stg|prd|sbx)$", var.environment))
    error_message = "The environment value must be in 3-charater format as follows => dev, sit, stg, prd, sbx."
  }
}

variable "region" {
  description = "Name of Azure Regions"
  type        = string
  default     = "southeastasia"
}
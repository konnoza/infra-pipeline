variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS cluster."
  type        = string
}

variable "aks_sku_tier" {
  description = "SKU of AKS cluster. Valid values are `Paid` or `Free`."
  type        = string
}

variable "aks_default_node_pool_size" {
  description = "VM size for default nodepool"
  type        = string
}

variable "aks_default_node_pool_os_disk_size_gb" {
  description = "The size of the OS Disk which should be used for each agent in the Node Pool. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "aks_default_node_pool_node_count" {
  description = "The initial number of nodes which should exist in this Node Pool. (1 - 1000)"
  type        = number
  default     = 2
}

variable "aks_default_node_pool_min_count" {
  description = "The initial number of nodes which should exist in this Node Pool. (1 - 1000)"
  type        = number
  default     = 2
}

variable "aks_default_node_pool_max_count" {
  description = "The maximum number of nodes which should exist in this Node Pool. (1 - 1000)"
  type        = number
  default     = 5
}

variable "aks_default_node_pool_upgrade_settings_max_surge" {
  description = "The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade."
  type        = number
  default     = 1
}

variable "aks_default_node_pool_availability_zones" {
  description = "Availability Zone for default node pool VMSS."
  type        = list(any)
  default     = null
}

variable "aks_default_node_pool_labels" {
  description = "Labels for default node pool VMSS."
  type        = map(string)
  default     = null
}

variable "aks_default_node_pool_only_critical_addons_enabled" {
  description = "Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint."
  type        = bool
  default     = false
}


variable "aks_default_node_pool_enable_auto_scaling" {
  description = "aks_default_node_pool_enable_auto_scaling"
  type        = bool
  default     = false
}

variable "aks_rbac_admin_group_object_ids" {
  description = "Object ID of AD group for AKS admin."
  type        = list(string)
  default     = []
}

variable "aks_additional_node_pools" {
  description = "List of additional node pools."
  type        = map(any)
}

variable "aks_automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`."
  type        = string
  default     = null
}

# variable "aks_additional_routes" {
#   type        = list(any)
#   description = "Additional Route for AKS"
#   default     = null
# }

# variable "aks_firewall_ip" {
#   type = string
# }

variable "maintenance_window_node_os_enabled" {
  description = "Specifies whether maintenance window for node-image should be enabled ?"
  type        = bool
  default     = false
}

variable "maintenance_window_node_os_frequency" {
  description = "Frequency of maintenance. Possible options are `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_interval" {
  description = "The interval for maintenance runs. Depending on the frequency this interval is week or month based."
  type        = number
  default     = 1
}

variable "maintenance_window_node_os_duration" {
  description = "The duration of the window for maintenance to run in hours."
  type        = number
  default     = 4
}

variable "maintenance_window_node_os_day_of_week" {
  description = "The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with `weekly` frequency."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_week_index" {
  description = "The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`. Required in combination with relative `monthly` frequency."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_start_date" {
  description = "The date on which the maintenance window begins to take effect."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_start_time" {
  description = "The time for maintenance to begin, based on the timezone determined by utc_offset. Format is `HH:mm`."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_utc_offset" {
  description = "Used to determine the timezone for cluster maintenance."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_not_allowed" {
  description = "Specifies whether the not allowed period should be enabled ?"
  type        = bool
  default     = false
}

variable "maintenance_window_node_os_not_allowed_start" {
  description = "The start of a time span, formatted as an RFC3339 string."
  type        = string
  default     = null
}

variable "maintenance_window_node_os_not_allowed_end" {
  description = "The end of a time span, formatted as an RFC3339 string."
  type        = string
  default     = null
}
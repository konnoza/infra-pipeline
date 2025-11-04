variable "cluster_name" {
  description = "The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_id" {
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
  type        = string
}

variable "create_route_table" {
  description = "Controls if separate route table for cluster subnet of AKS should be created."
  type        = bool
  default     = true
}

variable "route_table_name" {
  description = "Name of routing table to be attached in AKS node subnets."
  type        = string
  default     = null
}

variable "route_name" {
  description = "Name of route name to be added to routing table of AKS node subnets."
  type        = string
  default     = null
}

variable "additional_routes" {
  description = <<EOF
List of additional routes for adding to nodepool subnet:
```
list(object{
  route_name             = string
  address_prefix         = string
  next_hop_type          = string ==> VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None
  next_hop_in_ip_address = string (require only when "next_hop_type" = "VirtualAppliance")
})
```
**Note:** 0.0.0.0/0 will be filtered out.
EOF
  type        = list(any)
  default     = []
}

variable "firewall_ip" {
  description = "IP address of firewall for egress traffic"
  type        = string
  default     = null
}

variable "dns_prefix" {
  default = "DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
  type    = string
}

variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges to allow for incoming traffic to the server nodes."
  type        = list(string)
  default     = []
}

variable "api_server_delegated_subnet_id" {
  description = "The ID of the Subnet where the API server endpoint is delegated to."
  type        = string
  default     = null
}

variable "api_server_vnet_integration_enabled" {
  description = "Should [API Server VNet Integration](https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration) be enabled?"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster."
  type        = string
  default     = "Free"

  validation {
    condition     = can(regex("^(Free|Paid|Standard)$", var.sku_tier))
    error_message = "The valid values are Free and Standard."
  }
}

variable "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  type        = string
  default     = "blank"
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located."
  type        = bool
  default     = false
}

variable "cost_analysis_enabled" {
  description = "Should cost analysis be enabled for this Kubernetes Cluster?"
  type        = bool
  default     = false
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Specifies whether a Public FQDN for this Private Cluster should be added."
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "The ID of private dns zone for private cluser."
  type        = string
  default     = null
}

variable "dns_prefix_private_cluster" {
  description = "Specifies the DNS prefix to use with private clusters. Changing this forces a new resource to be created."
  type        = string
  default     = "blank"
}

variable "message_of_the_day" {
  description = "A base64-encoded string which will be written to /etc/motd after decoding. This allows customization of the message of the day for Linux nodes. It cannot be specified for Windows nodes and must be a static string (i.e. will be printed raw and not executed as a script). Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "temporary_name_for_rotation" {
  description = "Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing."
  type        = string
  default     = null
}

variable "default_node_pool_name" {
  description = "The name which should be used for the default Kubernetes Node Pool. Changing this forces a new resource to be created."
  type        = string
  default     = "default"
}

variable "default_node_pool_vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_availability_zones" {
  description = "A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "default_node_pool_os_sku" {
  description = "Specifies the OS SKU used by the agent pool. Possible values include: `AzureLinux`, `Ubuntu`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if `OSType`=`Linux` and `Windows2019` if `OSType`=`Windows`. And the default Windows OSSKU will be changed to `Windows2022` after `Windows2019` is deprecated."
  type        = string
  default     = "Ubuntu"
}

variable "default_node_pool_node_labels" {
  description = "A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}

variable "default_node_pool_only_critical_addons_enabled" {
  description = <<EOF
Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint.
EOF
  type        = bool
  default     = false
}

variable "default_node_pool_os_disk_size_gb" {
  description = "The size of the OS Disk which should be used for each agent in the Node Pool. Changing this forces a new resource to be created."
  type        = number
  default     = 30
}

variable "default_node_pool_os_disk_type" {
  description = "The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created."
  type        = string
  default     = "Managed"
}

variable "default_node_pool_ultra_ssd_enabled" {
  description = "Used to specify whether the UltraSSD is enabled in the Default Node Pool."
  type        = bool
  default     = false
}

variable "default_node_pool_vnet_subnet_id" {
  description = "The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool?"
  type        = bool
  default     = true
}

variable "default_node_pool_node_count" {
  description = "The initial number of nodes which should exist in this Node Pool. (1 - 1000)"
  type        = number
  default     = 1
}

variable "default_node_pool_max_count" {
  description = "The maximum number of nodes which should exist in this Node Pool. (1 - 1000)"
  type        = number
  default     = null
}

variable "default_node_pool_min_count" {
  description = "The initial number of nodes which should exist in this Node Pool. (1 - 1000)"
  type        = number
  default     = null
}

variable "default_node_pool_tags" {
  description = "The additional tags for default node pool"
  type        = map(string)
  default     = {}
}

variable "default_node_pool_upgrade_settings_max_surge" {
  description = "The maximum of nodes which will be added to the Node Pool size during an upgrade."
  type        = string
  default     = 1 // Default to 1 if not specified
  validation {
    condition     = var.default_node_pool_upgrade_settings_max_surge >= 0 && var.default_node_pool_upgrade_settings_max_surge <= 100
    error_message = "max_surge must be between 0 and 100."
  }
}

variable "default_node_pool_upgrade_settings_drain_timeout_in_minutes" {
  description = "The amount of time in minutes to wait on eviction of pods and graceful termination per node."
  type        = number
  default     = 0
}

variable "default_node_pool_upgrade_settings_node_soak_duration_in_minutes" {
  description = "The amount of time in minutes to wait after draining a node and before reimaging and moving on to next node."
  type        = number
  default     = 0
}

variable "default_node_pool_capacity_reservation_group_id" {
  description = "Specifies the ID of the Capacity Reservation Group within which this AKS Cluster should be created. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "default_node_pool_enable_host_encryption" {
  description = "Should the nodes in the Default Node Pool have host encryption enabled?"
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "Should nodes in this Node Pool have a Public IP Address? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "default_node_pool_node_public_ip_prefix_id" {
  description = "Resource ID for the Public IP Addresses Prefix for the nodes in this Node Pool. `enable_node_public_ip` should be `true`. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "default_node_pool_kubelet_disk_type" {
  description = "The type of disk used by kubelet. Possible values are `OS` and `Temporary`."
  type        = string
  default     = null
}

variable "default_node_pool_max_pods" {
  description = "The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = null
}

variable "default_node_pool_pod_subnet_id" {
  description = "The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "default_node_pool_kubelet_config" {
  description = <<EOT
The configurations for kubelet (Changing this forces a new resource to be created):
```
default_node_pool_kubelet_config = {
  allowed_unsafe_sysctls    = list(string) # Specifies the allow list of unsafe sysctls command or patterns (ending in *).
  container_log_max_line    = number       # pecifies the maximum number of container log files that can be present for a container. must be at least 2.
  container_log_max_size_mb = number       # Specifies the maximum size (e.g. 10MB) of container log file before it is rotated.
  cpu_cfs_quota_enabled     = bool         # Is CPU CFS quota enforcement for containers enabled?
  cpu_cfs_quota_period      = string       # Specifies the CPU CFS quota period value.
  cpu_manager_policy        = string       # Specifies the CPU Manager policy to use. Possible values are "none" and "static".
  image_gc_high_threshold   = number       # Specifies the percent of disk usage above which image garbage collection is always run. Must be between 0 and 100.
  image_gc_low_threshold    = number       # Specifies the percent of disk usage lower than which image garbage collection is never run. Must be between 0 and 100.
  pod_max_pid               = number       # Specifies the maximum number of processes per pod.
  topology_manager_policy   = string       # Specifies the Topology Manager policy to use. Possible values are "none", "best-effort", "restricted" or "single-numa-node".
}
```
EOT
  type        = map(any)
  default     = {}
}

variable "default_node_pool_linux_os_config" {
  description = <<EOT
The configurations for Linux OS (Changing this forces a new resource to be created):
```
default_node_pool_linux_os_config = {
  swap_file_size_mb                    = number # Specifies the size of swap file on each node in MB.
  sysctl_config                        = {
    fs_aio_max_nr                      = number # 65536 - 6553500
    fs_file_max                        = number # 8192 - 12000500
    fs_inotify_max_user_watches        = number # 781250 - 2097152
    fs_nr_open                         = number # 8192 - 20000500
    kernel_threads_max                 = number # 20 - 513785
    net_core_netdev_max_backlog        = number # 1000 - 3240000
    net_core_optmem_max                = number # 20480 - 4194304
    net_core_rmem_default              = number # 212992 - 134217728
    net_core_rmem_max                  = number # 212992 - 134217728
    net_core_somaxconn                 = number # 4096 - 3240000
    net_core_wmem_default              = number # 212992 - 134217728
    net_core_wmem_max                  = number # 212992 - 134217728
    net_ipv4_ip_local_port_range_max   = number # 1024 - 60999
    net_ipv4_ip_local_port_range_min   = number # 1024 - 60999
    net_ipv4_neigh_default_gc_thresh1  = number # 128 - 80000
    net_ipv4_neigh_default_gc_thresh2  = number # 512 - 90000
    net_ipv4_neigh_default_gc_thresh3  = number # 1024 - 100000
    net_ipv4_tcp_fin_timeout           = number # 5 - 120
    net_ipv4_tcp_keepalive_intvl       = number # 10 - 75
    net_ipv4_tcp_keepalive_probes      = number # 1 - 15
    net_ipv4_tcp_keepalive_time        = number # 30 - 432000
    net_ipv4_tcp_max_syn_backlog       = number # 128 - 3240000
    net_ipv4_tcp_max_tw_buckets        = number # 8000 - 1440000
    net_ipv4_tcp_tw_reuse              = bool
    net_netfilter_nf_conntrack_buckets = number # 65536 - 147456
    net_netfilter_nf_conntrack_max     = number # 131072 - 1048576
    vm_max_map_count                   = number # 65530 - 262144
    vm_swappiness                      = number # 0 - 100
    vm_vfs_cache_pressure              = number # 0 - 100
  }
  transparent_huge_page_defrag         = number # "always", "defer", "defer+madvise", "madvise" and "never"
  transparent_huge_page_enabled        = string # "always", "madvise" and "never"
}
```
EOT
  type        = map(any)
  default     = {}
}

variable "default_node_pool_fips_enabled" {
  description = "Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created. [more](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools#add-a-fips-enabled-node-pool-preview)"
  type        = bool
  default     = false
}

variable "default_node_pool_host_group_id" {
  description = "Specifies the ID of the Host Group within which this AKS Cluster should be created. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "default_node_pool_scale_down_mode" {
  description = "Specifies the autoscaling behaviour of the Kubernetes Cluster. Allowed values are `Delete` and `Deallocate`."
  type        = string
  default     = "Delete"
}

variable "default_node_pool_workload_runtime" {
  description = "Specifies the workload runtime used by the node pool. Possible values are `OCIContainer` and `KataMshvVmIsolation`."
  type        = string
  default     = null
}

variable "default_node_pool_custom_ca_trust_enabled" {
  description = "Specifies whether to trust a [Custom CA](https://learn.microsoft.com/en-us/azure/aks/custom-certificate-authority)"
  type        = bool
  default     = false
}

variable "default_node_pool_node_network_profile_enabled" {
  description = "Is node network profile enabled?"
  type        = bool
  default     = false
}

variable "default_node_pool_node_network_profile_node_public_ip_tags" {
  description = "Specifies a mapping of tags to the instance-level public IPs."
  type        = map(string)
  default     = null
}

variable "default_node_pool_snapshot_id" {
  description = "The ID of the Snapshot which should be used to create this default Node Pool."
  type        = string
  default     = null
}

variable "custom_ca_trust_certificates_base64" {
  description = "A list of up to 10 base64 encoded CAs that will be added to the trust store on nodes with the `custom_ca_trust_enabled` feature enabled."
  type        = list(string)
  default     = null
}

variable "addon_profile_aci_connector_linux_enabled" {
  description = "Is the virtual node addon enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_aci_connector_linux_subnet_name" {
  description = "The subnet name for the virtual nodes to run."
  type        = string
  default     = null
}

variable "addon_profile_azure_policy_enabled" {
  description = " Is the Azure Policy for Kubernetes Add On enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_http_application_routing_enabled" {
  description = "Is HTTP Application Routing Enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_ingress_application_gateway_enabled" {
  description = "Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster?"
  type        = bool
  default     = false
}

variable "addon_profile_ingress_application_gateway_gateway_id" {
  description = "The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "addon_profile_ingress_application_gateway_gateway_name" {
  description = "The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. "
  type        = string
  default     = null
}

variable "addon_profile_ingress_application_gateway_subnet_cidr" {
  description = "Whether to deploy tThe subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "addon_profile_ingress_application_gateway_subnet_id" {
  description = "The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "addon_profile_oms_agent_enabled" {
  description = "Is the OMS Agent Enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_oms_agent_role_assignment_enabled" {
  description = "Specify whether role assignment for OMS agent identity should be enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_oms_agent_log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace which the OMS Agent should send data to. "
  type        = string
  default     = null
}

variable "addon_profile_oms_agent_msi_auth_for_monitoring_enabled" {
  description = "Is managed identity authentication for monitoring enabled ?"
  type        = bool
  default     = false
}

variable "addon_profile_open_service_mesh_enabled" {
  description = "An open_service_mesh block as defined below. For more details, please visit [Open Service Mesh for AKS](https://docs.microsoft.com/azure/aks/open-service-mesh-about)."
  type        = bool
  default     = false
}

variable "addon_profile_azure_keyvault_secrets_provider_enabled" {
  description = "An azure_keyvault_secrets_provider block as defined below. For more details, please visit [Azure Keyvault Secrets Provider for AKS](https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)."
  type        = bool
  default     = false
}

variable "addon_profile_azure_keyvault_secrets_provider_secret_rotation_enabled" {
  description = "Is secret rotation enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_azure_keyvault_secrets_provider_secret_rotation_interval" {
  description = "The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true`."
  type        = string
  default     = "2m"
}

variable "addon_profile_azure_keyvault_secrets_provider_attach_keyvault_enabled" {
  description = "Specify whether to attach Azure Key Vault."
  type        = bool
  default     = true
}

variable "addon_profile_azure_keyvault_secrets_provider_attach_keyvault_id" {
  description = "The ID of Azure Key Vault that will be attach to this AKS."
  type        = string
  default     = null
}

variable "addon_profile_azure_keyvault_secrets_provider_attach_keyvault_cert_perms" {
  description = "Permissions for kubelet identity to access certificates in Azure Key Vault."
  type        = list(string)
  default     = ["Get", "List", ]
}

variable "addon_profile_azure_keyvault_secrets_provider_attach_keyvault_key_perms" {
  description = "Permissions for kubelet identity to access keys in Azure Key Vault."
  type        = list(string)
  default     = ["Get", "List", ]
}

variable "addon_profile_azure_keyvault_secrets_provider_attach_keyvault_secret_perms" {
  description = "Permissions for kubelet identity to access secrets in Azure Key Vault."
  type        = list(string)
  default     = ["Get", "List", ]
}

variable "addon_profile_oidc_issuer_enabled" {
  description = "Enable or Disable the [OIDC issuer URL](https://docs.microsoft.com/azure/aks/cluster-configuration#oidc-issuer-preview)"
  type        = bool
  default     = false
}

variable "addon_profile_workload_identity_enabled" {
  description = "Specifies whether Azure AD Workload Identity should be enabled for the Cluster. To enable Azure AD Workload Identity `addon_profile_oidc_issuer_enabled` must be set to `true`."
  type        = bool
  default     = false
}

variable "addon_profile_run_command_enabled" {
  description = "Specify whether to enable run command for the cluster or not? [more](https://docs.microsoft.com/en-us/azure/aks/command-invoke)"
  type        = bool
  default     = true
}

variable "addon_profile_microsoft_defender_enabled" {
  description = "Specify whether to enable Microsoft Defender for Containers? [more](https://docs.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-enable?)"
  type        = bool
  default     = false
}

variable "addon_profile_microsoft_defender_log_analytics_workspace_id" {
  description = "Specifies the ID of the Log Analytics Workspace where the audit logs collected by Microsoft Defender should be sent to."
  type        = string
  default     = null
}

variable "addon_profile_workload_autoscaler_keda_enabled" {
  description = "Specifies whether [KEDA Autoscaler](https://learn.microsoft.com/en-us/azure/aks/keda-about) can be used for workloads."
  type        = bool
  default     = false
}

variable "addon_profile_workload_autoscaler_vpa_enabled" {
  description = "Specifies whether [Vertical Pod Autoscaler](https://learn.microsoft.com/en-us/azure/aks/vertical-pod-autoscaler) should be enabled."
  type        = bool
  default     = false
}

variable "addon_profile_web_app_routing_enabled" {
  description = "Specifies whether to enable [Managed nginx ingress with the application routing add-on](https://learn.microsoft.com/en-us/azure/aks/app-routing?tabs=without-osm)"
  type        = bool
  default     = false
}

variable "addon_profile_web_app_routing_dns_zone_id" {
  description = "Specifies the ID of the DNS Zone in which DNS entries are created for applications deployed to the cluster when Web App Routing is enabled. For Bring-Your-Own DNS zones this property should be set to an empty string `\"\"`."
  type        = list(string)
  default     = []
}

variable "addon_profile_service_mesh_profile_enabled" {
  description = "Specifies whether Service Mesh should be enabled ?"
  type        = bool
  default     = false
}

variable "addon_profile_service_mesh_profile_mode" {
  description = "The mode of the service mesh. Possible value is `Istio`."
  type        = string
  default     = "Istio"
}

variable "addon_profile_service_mesh_profile_internal_ingress_gateway_enabled" {
  description = "Is Istio Internal Ingress Gateway enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_service_mesh_profile_external_ingress_gateway_enabled" {
  description = "Is Istio External Ingress Gateway enabled?"
  type        = bool
  default     = false
}

variable "addon_profile_service_mesh_profile_certificate_authority" {
  description = "Is Istio External Ingress Gateway enabled?"
  type        = string
  default     = null
}

variable "addon_profile_service_mesh_profile_revisions" {
  description = "Specify 1 or 2 Istio control plane revisions for managing minor upgrades using the canary upgrade process."
  type        = list(string)
  default     = []
}


variable "auto_scaler_profile" {
  description = <<EOT
The configurations for autoscaler:
```
auto_scaler_profile = {
  balance_similar_node_groups      = bool   # Detect similar node groups and balance the number of nodes between them. Defaults to false.
  expander                         = string # Expander to use. Possible values are "least-waste", "priority", "most-pods" and "random". Defaults to "random".
  max_graceful_termination_sec     = number # Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to 600.
  max_node_provisioning_time       = string # Maximum time the autoscaler waits for a node to be provisioned. Defaults to "15m".
  max_unready_nodes                = number # Maximum Number of allowed unready nodes. Defaults to 3.
  max_unready_percentage           = number # Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to 45.
  new_pod_scale_up_delay           = string # For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to "10s".
  scan_interval                    = string # How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to "10s".
  scale_down_delay_after_add       = string # How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to "10m".
  scale_down_delay_after_delete    = string # How long after node deletion that scale down evaluation resumes. Defaults to the value used for `scan_interval`.
  scale_down_delay_after_failure   = string # How long after scale down failure that scale down evaluation resumes. Defaults to "3m".
  scale_down_unneeded              = string # How long a node should be unneeded before it is eligible for scale down. Defaults to "10m".
  scale_down_unready               = string # How long an unready node should be unneeded before it is eligible for scale down. Defaults to "20m".
  scale_down_utilization_threshold = string # Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to "0.5".
  empty_bulk_delete_max            = number # Maximum number of empty nodes that can be deleted at the same time. Defaults to 10.
  skip_nodes_with_local_storage    = bool   # If `true` cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to true.
  skip_nodes_with_system_pods      = bool   # If `true` cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to true.
}
```
EOT
  type        = map(any)
  default     = {}
}

variable "identity_type" {
  description = "The type of identity used for the managed cluster. "
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = can(regex("^(SystemAssigned|ManagedIdentity|ServicePrincipal)$", var.identity_type))
    error_message = "The valid values are SystemAssigned, ManagedIdentity and ServicePrincipal."
  }
}

variable "identity_id" {
  description = "The ID of user assigned identity for AKS to use"
  type        = string
  default     = null
}

variable "identity_principal_id" {
  description = "The principal ID of user assigned identity for AKS to use"
  type        = string
  default     = null
}

variable "identity_app_id" {
  description = "The Application (Client) ID for the Service Principal."
  type        = string
  default     = null
}

variable "identity_app_secret" {
  description = "The Application (Client) Secret for the Service Principal."
  type        = string
  default     = null
}

variable "windows_profile_enable" {
  description = "Specify profile for window-based worker nodes"
  type        = bool
  default     = false
}

variable "windows_profile_admin_username" {
  description = "The Admin Username for Windows VMs."
  type        = string
  default     = ""
}

variable "windows_profile_admin_password" {
  description = "The Admin Password for Windows VMs. Length must be between 14 and 123 characters."
  type        = string
  default     = null
}

variable "windows_profile_gmsa_dns_server" {
  description = "Specifies the DNS server for Windows gMSA. Set this to an empty string if you have configured the DNS server in the VNet which was used to create the managed cluster."
  type        = string
  default     = null
}

variable "windows_profile_gmsa_root_domain" {
  description = "Specifies the root domain name for Windows gMSA. Set this to an empty string if you have configured the DNS server in the VNet which was used to create the managed cluster."
  type        = string
  default     = null
}

variable "linux_profile_enable" {
  description = "Specify profile for linux-based worker nodes"
  type        = bool
  default     = true
}

variable "linux_profile_admin_username" {
  description = "The Admin Username for the Cluster. Changing this forces a new resource to be created."
  type        = string
  default     = "aksadmin"
}

variable "linux_profile_public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  type        = string
  default     = ""
}

variable "linux_profile_key_vault_storage_enabled" {
  description = "Specify whether to store private ssh key to key vault. if `true`, `key_vault_id` must be supplied."
  type        = bool
  default     = false
}

variable "linux_profile_public_ssh_key_key_vault_id" {
  description = "ID of key vault to store generated ssh key."
  type        = string
  default     = ""
}

variable "maintenance_window_allowed" {
  description = "Does maintenance allowed?"
  type        = bool
  default     = false
}

variable "maintenance_window_allowed_day" {
  description = "A day in a week which maintenance is allowed?"
  type        = string
  default     = "Monday"

  validation {
    condition     = can(regex("^(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)$", var.maintenance_window_allowed_day))
    error_message = "The valid values are Sunday, Monday, Tuesday, Wednesday, Thursday, Friday and Saturday."
  }
}

variable "maintenance_window_allowed_hours" {
  description = "An array of hour slots in a day which maintenance is allowed?"
  type        = list(number)
  default     = [3]
}

variable "maintenance_window_not_allowed" {
  description = "Is there a period that maintenance is not allowed?"
  type        = bool
  default     = false
}

variable "maintenance_window_not_allowed_start" {
  description = "The start of a time span, formatted as an RFC3339 string."
  type        = string
  default     = null
}
variable "maintenance_window_not_allowed_end" {
  description = "The end of a time span, formatted as an RFC3339 string."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_enabled" {
  description = "Specifies whether maintenance window auto upgrade should be enabled ?"
  type        = bool
  default     = false
}

variable "maintenance_window_auto_upgrade_frequency" {
  description = "Frequency of maintenance. Possible options are `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_interval" {
  description = "The interval for maintenance runs. Depending on the frequency this interval is week or month based."
  type        = number
  default     = 1
}

variable "maintenance_window_auto_upgrade_duration" {
  description = "The duration of the window for maintenance to run in hours."
  type        = number
  default     = 4
}

variable "maintenance_window_auto_upgrade_day_of_week" {
  description = "The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with `weekly` frequency."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_week_index" {
  description = "The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`. Required in combination with relative `monthly` frequency."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_start_date" {
  description = "The date on which the maintenance window begins to take effect."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_start_time" {
  description = "The time for maintenance to begin, based on the timezone determined by utc_offset. Format is `HH:mm`."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_utc_offset" {
  description = "Used to determine the timezone for cluster maintenance."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_not_allowed" {
  description = "Specifies whether the not allowed period should be enabled ?"
  type        = bool
  default     = false
}

variable "maintenance_window_auto_upgrade_not_allowed_start" {
  description = "The start of a time span, formatted as an RFC3339 string."
  type        = string
  default     = null
}

variable "maintenance_window_auto_upgrade_not_allowed_end" {
  description = "The end of a time span, formatted as an RFC3339 string."
  type        = string
  default     = null
}


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

variable "network_profile_network_plugin" {
  description = "Network plugin to use for networking."
  type        = string
  default     = "kubenet"

  validation {
    condition     = can(regex("^(azure|kubenet|none)$", var.network_profile_network_plugin))
    error_message = "The valid values are azure and kubenet."
  }
}

variable "network_profile_network_plugin_mode" {
  description = "Specifies the network plugin mode used for building the Kubernetes network. Possible value is `Overlay`."
  type        = string
  default     = "overlay"
}

variable "network_profile_network_policy" {
  description = "Sets up network policy to be used with Azure CNI. [Network policy allows us to control the traffic flow between pods](https://docs.microsoft.com/azure/aks/use-network-policies). Currently supported values are `calico` and `azure`"
  type        = string
  default     = "calico"
}

variable "network_profile_ip_versions" {
  description = "Specifies a list of IP versions the Kubernetes Cluster will use to assign IP addresses to its nodes and pods. Possible values are `IPv4` and/or `IPv6`. `IPv4` must always be specified."
  type        = list(string)
  default     = ["IPv4", ]
}

variable "network_profile_dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  type        = string
  default     = "100.64.0.10"
}

variable "network_profile_network_data_plane" {
  description = "Specifies the data plane used for building the Kubernetes network."
  type        = string
  default     = "azure"
}

variable "network_profile_docker_bridge_cidr" {
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "network_profile_service_cidr" {
  description = "The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = "100.64.0.0/16"
}

variable "network_profile_pod_cidr" {
  description = "The CIDR to use for pod IP addresses. This field can only be set when `network_plugin` is set to `kubenet`. Changing this forces a new resource to be created."
  type        = string
  default     = "100.65.0.0/16"
}

variable "network_profile_service_cidrs" {
  description = "A list of CIDRs to use for Kubernetes services. For single-stack networking a single IPv4 CIDR is expected. For dual-stack networking an IPv4 and IPv6 CIDR are expected. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["100.64.0.0/16", ]
}

variable "network_profile_pod_cidrs" {
  description = "A list of CIDRs to use for pod IP addresses. For single-stack networking a single IPv4 CIDR is expected. For dual-stack networking an IPv4 and IPv6 CIDR are expected. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["100.65.0.0/16", ]
}

variable "network_profile_load_balancer_sku" {
  description = "Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`."
  type        = string
  default     = "standard"
}

variable "load_balancer_profile_idle_timeout_in_minutes" {
  description = "Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between `4` and `120` inclusive."
  type        = number
  default     = 30
}

variable "load_balancer_profile_managed_outbound_ip_count" {
  description = "Count of desired managed outbound IPs for the cluster load balancer. Must be between `1` and `100` inclusive."
  type        = number
  default     = null
}

variable "load_balancer_profile_managed_outbound_ipv6_count" {
  description = "The desired number of IPv6 outbound IPs created and managed by Azure for the cluster load balancer. Must be in the range of 1 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack."
  type        = number
  default     = null
}

variable "load_balancer_profile_outbound_ip_address_ids" {
  description = " The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer."
  type        = list(string)
  default     = null
}

variable "load_balancer_profile_outbound_ip_prefix_ids" {
  description = "The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer."
  type        = list(string)
  default     = null
}

variable "load_balancer_profile_outbound_ports_allocated" {
  description = "Number of desired SNAT port for each VM in the clusters load balancer. Must be between `0` and `64000` inclusive."
  type        = number
  default     = null
}

variable "nat_gateway_profile_idle_timeout_in_minutes" {
  description = "Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between `4` and `120` inclusive."
  type        = number
  default     = null
}

variable "nat_gateway_profile_managed_outbound_ip_count" {
  description = "Count of desired managed outbound IPs for the cluster load balancer. Must be between `1` and `100` inclusive."
  type        = number
  default     = null
}

variable "network_profile_outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster."
  type        = string
  default     = "loadBalancer"

  # validation {
  #   condition     = can(regex("^(loadBalancer|userDefinedRouting)$", var.network_profile_outbound_type))
  #   error_message = "The valid values are loadBalancer and userDefinedRouting."
  # }
}

variable "rbac_enabled" {
  description = "Is Role Based Access Control Enabled?"
  type        = bool
  default     = false
}

variable "local_account_disabled" {
  description = "Specify whether to disable local accounts? [more](https://docs.microsoft.com/en-us/azure/aks/managed-aad#disable-local-accounts)"
  type        = bool
  default     = false
}

variable "rbac_aad_managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = false
}

variable "rbac_aad_tenant_id" {
  description = "The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
  type        = string
  default     = null
}

variable "rbac_aad_client_app_id" {
  description = "The Client ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_id" {
  description = "The Server ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_secret" {
  description = "The Server Secret of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_admin_group_object_ids" {
  description = "A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "node_pools" {
  description = <<EOF
Map of node pools:
```
{  
  "name" = {
      tags                          = map(string) # "{ "pool" : "special01" }
      mode                          = string # System and User
      orchestrator_version          = string
      workload_runtime              = string # OCIContainer and KataMshvVmIsolation
      os_type                       = string # Linux and Windows
      os_sku                        = string # Linux => `AzureLinux`, `Ubuntu` | Windows => `Windows2019`, `Windows2022`
      os_disk_size_gb               = numbernode_taints
      os_disk_type                  = string # Ephemeral and Managed
      vm_size                       = string # "Standard_DS2_v2"
      vnet_subnet_id                = string # As of now, put null to let it be in the same subnet as the rest node pools in the cluster.
      pod_subnet_id                 = string
      availability_zones            = list(string) # e.g. specific zone => ["1", "2", "3"], not specific zone => null
      max_pods                      = number
      enable_host_encryption        = bool
      enable_node_public_ip         = bool
      node_public_ip_prefix_id      = string
      ultra_ssd_enabled             = bool
      fips_enabled                  = bool
      host_group_id                 = string
      snapshot_id                   = string
      enable_auto_scaling           = bool
      scale_down_mode               = bool
      max_count                     = 10
      min_count                     = 1
      node_count                    = 1
      priority                      = "Regular" # Regular and Spot
      spot_max_price                = number # Required if `priority=Spot`
      eviction_policy               = string # Spot => Deallocate and Delete, Regular => null
      node_labels                   = map(string)  # e.g. { "aaaa" : "1111", "bbbb" : "2222" }
      node_taints                   = list(string) # e.g. ["taint=real1:NoSchedule"]
      proximity_placement_group_id  = string
      capacity_reservation_group_id = string
      upgrade_settings_max_surge    = string # e.g. "1" or "25%"
      kubelet_disk_type             = string # OS and Temporary
      kubelet_config                = {
        allowed_unsafe_sysctls    = list(string) # null or [ "kernel.shm*", "kernel.msg*", ]
        container_log_max_line    = number
        container_log_max_size_mb = number
        cpu_cfs_quota_enabled     = bool
        cpu_cfs_quota_period      = string # e.g. "10m"
        cpu_manager_policy        = string # none, static
        image_gc_high_threshold   = number # 0-100
        image_gc_low_threshold    = number # 0-100
        pod_max_pid               = number
        topology_manager_policy   = string # e.g. none, best-effort, restricted, single-numa-node
      }
      linux_os_config                        = {
        swap_file_size_mb                    = number
        transparent_huge_page_defrag         = string # e.g. always, defer, defer+madvise, madvise, never
        transparent_huge_page_enabled        = string # e.g. always, madvise, never
        sysctl_config                        = {
          fs_aio_max_nr                      = number # 65536 - 6553500
          fs_file_max                        = number # 8192 - 12000500
          fs_inotify_max_user_watches        = number # 781250 - 2097152
          fs_nr_open                         = number # 8192 - 20000500
          kernel_threads_max                 = number # 20 - 513785
          net_core_netdev_max_backlog        = number # 1000 - 3240000
          net_core_optmem_max                = number # 20480 - 4194304
          net_core_rmem_default              = number # 212992 - 134217728
          net_core_rmem_max                  = number # 212992 - 134217728
          net_core_somaxconn                 = number # 4096 - 3240000
          net_core_wmem_default              = number # 212992 - 134217728
          net_core_wmem_max                  = number # 212992 - 134217728
          net_ipv4_ip_local_port_range_max   = number # 1024 - 60999
          net_ipv4_ip_local_port_range_min   = number # 1024 - 60999
          net_ipv4_neigh_default_gc_thresh1  = number # 128 - 80000
          net_ipv4_neigh_default_gc_thresh2  = number # 512 - 90000
          net_ipv4_neigh_default_gc_thresh3  = number # 1024 - 100000
          net_ipv4_tcp_fin_timeout           = number # 5 - 120
          net_ipv4_tcp_keepalive_intvl       = number # 10 - 75
          net_ipv4_tcp_keepalive_probes      = number # 1 - 15
          net_ipv4_tcp_keepalive_time        = number # 30 - 432000
          net_ipv4_tcp_max_syn_backlog       = number # 128 - 3240000
          net_ipv4_tcp_max_tw_buckets        = number # 8000 - 1440000
          net_ipv4_tcp_tw_reuse              = bool
          net_netfilter_nf_conntrack_buckets = number # 65536 - 147456
          net_netfilter_nf_conntrack_max     = number # 131072 - 1048576
          vm_max_map_count                   = number # 65530 - 262144
          vm_swappiness                      = number # 0 - 100
          vm_vfs_cache_pressure              = number # 0 - 100
        }
      }
      windows_profile  = {
        outbound_nat_enabled = bool
      }
      node_network_profile = {
        node_public_ip_tags = map(string)
      }
  },
}
```
EOF
  type        = map(any)
  default     = {}
}

variable "enable_attach_acr" {
  description = "Enable ACR Pull attach. Needs acr_id to be defined."
  type        = bool
  default     = false
}

variable "acr_id" {
  description = "Attach ACR ID to allow ACR Pull from the SP/Managed Indentity."
  type        = string
  default     = null
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are `none`, `patch`, `rapid`, `node-image` and `stable`."
  type        = string
  default     = null
}

variable "node_os_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`."
  type        = string
  default     = null
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. Changing this forces a new resource to be created. [more](https://docs.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys)"
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "image_cleaner_enabled" {
  description = "Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = false
}

variable "image_cleaner_interval_hours" {
  description = "Specifies the interval in hours when images should be cleaned up."
  type        = number
  default     = 48
}

variable "http_proxy_config_enabled" {
  description = "Specify whether to let communication over HTTP via proxy?"
  type        = bool
  default     = false
}

variable "http_proxy_config_http_proxy" {
  description = "The proxy address to be used when communicating over HTTP."
  type        = string
  default     = null
}

variable "http_proxy_config_https_proxy" {
  description = "The proxy address to be used when communicating over HTTPS."
  type        = string
  default     = null
}

variable "http_proxy_config_no_proxys" {
  description = "The list of domains that will not use the proxy for communication."
  type        = list(any)
  default     = []
}

variable "http_proxy_config_trusted_ca" {
  description = "The base64 encoded alternative CA certificate content in PEM format."
  type        = string
  default     = null
}

variable "kubelet_identity_enabled" {
  description = "Specify whether to assigne user-defined Managed Identity to the Kubelets?"
  type        = bool
  default     = false
}

variable "kubelet_identity_client_id" {
  description = "The Client ID of the user-defined Managed Identity to be assigned to the Kubelets. If not specified a Managed Identity is created automatically."
  type        = string
  default     = null
}

variable "kubelet_identity_object_id" {
  description = "The Object ID of the user-defined Managed Identity assigned to the Kubelets.If not specified a Managed Identity is created automatically."
  type        = string
  default     = null
}

variable "kubelet_identity_user_assigned_identity_id" {
  description = "The ID of the User Assigned Identity assigned to the Kubelets. If not specified a Managed Identity is created automatically."
  type        = string
  default     = null
}

variable "storage_profile_blob_driver_enabled" {
  description = "Is the Blob CSI driver enabled?"
  type        = bool
  default     = false
}

variable "storage_profile_disk_driver_enabled" {
  description = "Is the Disk CSI driver enabled?"
  type        = bool
  default     = true
}

variable "storage_profile_file_driver_enabled" {
  description = "Is the File CSI driver enabled?"
  type        = bool
  default     = true
}

variable "storage_profile_snapshot_controller_enabled" {
  description = "Is the Snapshot Controller enabled?"
  type        = bool
  default     = true
}

variable "monitor_metrics_enabled" {
  description = "Is [Prometheus Addon](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-enable?tabs=azure-portal) (Microsoft.ContainerService/AKS-PrometheusAddonPreview) enabled?"
  type        = bool
  default     = false
}

variable "monitor_metrics_annotations_allowed" {
  description = "Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "monitor_metrics_labels_allowed" {
  description = "Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "kms_enabled" {
  description = "Specify whether to [Key Management Service (KMS) plugin for etcd](https://learn.microsoft.com/en-us/azure/aks/use-kms-etcd-encryption)?"
  type        = bool
  default     = false
}

variable "kms_key_vault_key_id" {
  description = "Identifier of Azure Key Vault key. See [key identifier format](https://learn.microsoft.com/en-us/azure/key-vault/general/about-keys-secrets-certificates#vault-name-and-object-name) for more details."
  type        = string
  default     = null
}

variable "kms_key_vault_network_access" {
  description = "Network access of the key vault Network access of key vault. The possible values are `Public` (the key vault allows public access from all networks) and `Private` (the key vault disables public access and enables private link)."
  type        = string
  default     = "Public"
}

variable "sgx_quote_helper_enabled" {
  description = "Should the SGX quote helper be enabled ?"
  type        = bool
  default     = false
}

variable "create_network_contributor_role" {
  description = "Normally this module to will create network contributor role on the resource group where AKS exist. If set to `false`, you have to take care of this yourselves."
  type        = bool
  default     = true
}

#
# Diagnostic Settings
# 

variable "diagnostic_settings" {
  description = <<EOT
List of diagnotic settings for this resource.
```
{
  suffix_name                    = string
  enabled_logs                   = list(string) # ["kube-audit", "guard", "cluster-autoscaler", "kube-audit-admin", "kube-scheduler", "kube-controller-manager", "kube-apiserver", "cloud-controller-manager", "csi-azuredisk-controller", "csi-azurefile-controller", "csi-snapshot-controller", ]
  enabled_categories             = list(string) # []
  metric                         = list(string) # ["AllMetrics",]
  log                            = list(string) # Same as `enabled_logs` but log will be deprecated in AzureRM 4.0
  storage_account_id             = string
  log_analytics_workspace_id     = string
  log_analytics_destination_type = string # "AzureDiagnostics" or "Dedicated"
  eventhub_authorization_rule_id = string
  eventhub_name                  = string
  partner_solution_id            = string
},
```
EOT
  type        = list(any)
  default     = []
}

locals {
  node_resource_group        = var.node_resource_group == "blank" ? replace(var.cluster_name, "/^aks-/", "rg-Aks") : var.node_resource_group
  dns_prefix_private_cluster = var.dns_prefix_private_cluster == "blank" ? var.dns_prefix : var.dns_prefix_private_cluster
  additional_routes          = [for x in var.additional_routes : x if x.address_prefix != "0.0.0.0/0"]
}
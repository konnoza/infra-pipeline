/*
*
* # Terraform Module to Create Azure Kubernetes Service Cluster
*
*/

module "ssh-key" {
  source = "../ssh-key"

  public_ssh_key            = var.linux_profile_public_ssh_key
  hostname                  = var.cluster_name
  key_vault_storage_enabled = var.linux_profile_key_vault_storage_enabled
  key_vault_id              = var.linux_profile_public_ssh_key_key_vault_id
}

# ------ Role Assignment [Network Contributor]-----------------------------------------------------------------------------------------------------------------------------

resource "azurerm_role_assignment" "network_id" {
  count = var.create_network_contributor_role && var.identity_type == "ManagedIdentity" ? 1 : 0

  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = var.identity_principal_id
}

resource "azurerm_role_assignment" "network_sp" {
  count = var.create_network_contributor_role && var.identity_type == "ServicePrincipal" ? 1 : 0

  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = var.identity_app_id
}

# ------ Route Table ------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_route_table" "main" {
  count = var.create_route_table && var.network_profile_outbound_type == "userDefinedRouting" ? 1 : 0

  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      route,
      tags # Azure bug can't update tag after apply
    ]
  }
}

resource "azurerm_route" "main" {
  count = var.create_route_table && var.network_profile_outbound_type == "userDefinedRouting" ? 1 : 0

  name                   = var.route_name
  resource_group_name    = var.resource_group_name
  route_table_name       = var.route_table_name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip

  depends_on = [
    azurerm_route_table.main,
  ]
}

resource "azurerm_subnet_route_table_association" "main" {
  count = var.create_route_table && var.network_profile_outbound_type == "userDefinedRouting" ? 1 : 0

  subnet_id      = var.default_node_pool_vnet_subnet_id
  route_table_id = azurerm_route_table.main.0.id

  depends_on = [
    azurerm_route_table.main,
    azurerm_route.main,
  ]
}

# ------ AKS -------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "main" {

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      default_node_pool[0].min_count,
      default_node_pool[0].max_count,
      default_node_pool[0].tags
    ]
  }

  depends_on = [
    azurerm_role_assignment.network_id,
    azurerm_role_assignment.network_sp,
    azurerm_subnet_route_table_association.main,
  ]

  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dns_prefix                 = var.dns_prefix
  dns_prefix_private_cluster = var.dns_prefix != "" ? null : local.dns_prefix_private_cluster

  kubernetes_version           = var.kubernetes_version
  sku_tier                     = var.sku_tier
  node_resource_group          = local.node_resource_group
  automatic_channel_upgrade    = var.automatic_channel_upgrade                                                             # Azure RM v4 change to automatic_upgrade_channel
  node_os_channel_upgrade      = var.automatic_channel_upgrade == "node-image" ? "NodeImage" : var.node_os_channel_upgrade # Azure RM v4 change to node_os_upgrade_channel -
  disk_encryption_set_id       = var.disk_encryption_set_id
  edge_zone                    = var.edge_zone
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = var.private_dns_zone_id

  # kube cost analysis
  cost_analysis_enabled = var.sku_tier == "Free" ? null : var.cost_analysis_enabled

  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }

  default_node_pool {
    orchestrator_version         = var.kubernetes_version
    name                         = var.default_node_pool_name
    vm_size                      = var.default_node_pool_vm_size
    zones                        = var.default_node_pool_availability_zones
    vnet_subnet_id               = var.default_node_pool_vnet_subnet_id
    node_labels                  = var.default_node_pool_node_labels
    only_critical_addons_enabled = var.default_node_pool_only_critical_addons_enabled
    os_sku                       = var.default_node_pool_os_sku
    os_disk_size_gb              = var.default_node_pool_os_disk_size_gb
    os_disk_type                 = var.default_node_pool_os_disk_type
    type                         = "VirtualMachineScaleSets"
    temporary_name_for_rotation  = "${var.default_node_pool_name}tmp"
    enable_auto_scaling          = var.default_node_pool_enable_auto_scaling # Azure RM v4 change to auto_scaling_enabled
    node_count                   = var.default_node_pool_node_count
    min_count                    = var.default_node_pool_min_count
    max_count                    = var.default_node_pool_max_count

    dynamic "upgrade_settings" {
      for_each = var.default_node_pool_upgrade_settings_max_surge > 0 ? ["upgrade"] : []
      content {
        max_surge                     = var.default_node_pool_upgrade_settings_max_surge
        drain_timeout_in_minutes      = var.default_node_pool_upgrade_settings_drain_timeout_in_minutes
        node_soak_duration_in_minutes = var.default_node_pool_upgrade_settings_node_soak_duration_in_minutes
      }
    }

    tags = merge(var.default_node_pool_tags, var.tags)

    capacity_reservation_group_id = var.default_node_pool_capacity_reservation_group_id # null
    enable_host_encryption        = var.default_node_pool_enable_host_encryption        # false # Azure RM v4 change to host_encryption_enabled
    enable_node_public_ip         = var.default_node_pool_enable_node_public_ip         # false # Azure RM v4 change to node_public_ip_enabled
    node_public_ip_prefix_id      = var.default_node_pool_enable_node_public_ip ? var.default_node_pool_node_public_ip_prefix_id : null
    kubelet_disk_type             = var.default_node_pool_kubelet_disk_type                                                    # OS, Temporary
    max_pods                      = var.default_node_pool_max_pods                                                             # 110
    pod_subnet_id                 = var.network_profile_network_plugin == "azure" ? var.default_node_pool_pod_subnet_id : null # for AzureCNI
    ultra_ssd_enabled             = var.default_node_pool_ultra_ssd_enabled                                                    # false
    fips_enabled                  = var.default_node_pool_fips_enabled                                                         # false
    host_group_id                 = var.default_node_pool_host_group_id
    scale_down_mode               = var.default_node_pool_scale_down_mode
    workload_runtime              = var.default_node_pool_workload_runtime
    snapshot_id                   = var.default_node_pool_snapshot_id

    dynamic "kubelet_config" {
      for_each = length(var.default_node_pool_kubelet_config) > 0 ? ["create"] : []
      content {
        allowed_unsafe_sysctls    = lookup(var.default_node_pool_kubelet_config, "allowed_unsafe_sysctls", [])
        container_log_max_line    = lookup(var.default_node_pool_kubelet_config, "container_log_max_line", null)
        container_log_max_size_mb = lookup(var.default_node_pool_kubelet_config, "container_log_max_size_mb", null)
        cpu_cfs_quota_enabled     = lookup(var.default_node_pool_kubelet_config, "cpu_cfs_quota_enabled", null)
        cpu_cfs_quota_period      = lookup(var.default_node_pool_kubelet_config, "cpu_cfs_quota_period", null)
        cpu_manager_policy        = lookup(var.default_node_pool_kubelet_config, "cpu_manager_policy", null)
        image_gc_high_threshold   = lookup(var.default_node_pool_kubelet_config, "image_gc_high_threshold", null)
        image_gc_low_threshold    = lookup(var.default_node_pool_kubelet_config, "image_gc_low_threshold", null)
        pod_max_pid               = lookup(var.default_node_pool_kubelet_config, "pod_max_pid", null)
        topology_manager_policy   = lookup(var.default_node_pool_kubelet_config, "topology_manager_policy", null)
      }
    }

    dynamic "linux_os_config" {
      for_each = length(var.default_node_pool_linux_os_config) > 0 ? ["create"] : []
      content {
        swap_file_size_mb = lookup(var.default_node_pool_linux_os_config, "swap_file_size_mb", null)
        dynamic "sysctl_config" {
          for_each = length(lookup(var.default_node_pool_linux_os_config, "sysctl_config", {})) > 0 ? ["create"] : []
          content {
            fs_aio_max_nr                      = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "fs_aio_max_nr", null)                      # 65536 - 6553500
            fs_file_max                        = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "fs_file_max", null)                        # 8192 - 12000500
            fs_inotify_max_user_watches        = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "fs_inotify_max_user_watches", null)        # 781250 - 2097152
            fs_nr_open                         = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "fs_nr_open", null)                         # 8192 - 20000500
            kernel_threads_max                 = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "kernel_threads_max", null)                 # 20 - 513785
            net_core_netdev_max_backlog        = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_netdev_max_backlog", null)        # 1000 - 3240000
            net_core_optmem_max                = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_optmem_max", null)                # 20480 - 4194304
            net_core_rmem_default              = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_optmem_max", null)                # 212992 - 134217728
            net_core_rmem_max                  = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_rmem_max", null)                  # 212992 - 134217728
            net_core_somaxconn                 = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_somaxconn", null)                 # 4096 - 3240000
            net_core_wmem_default              = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_wmem_default", null)              # 212992 - 134217728
            net_core_wmem_max                  = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_core_wmem_max", null)                  # 212992 - 134217728
            net_ipv4_ip_local_port_range_max   = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_ip_local_port_range_max", null)   # 1024 - 60999
            net_ipv4_ip_local_port_range_min   = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_ip_local_port_range_min", null)   # 1024 - 60999
            net_ipv4_neigh_default_gc_thresh1  = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_neigh_default_gc_thresh1", null)  # 128 - 80000
            net_ipv4_neigh_default_gc_thresh2  = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_neigh_default_gc_thresh2", null)  # 512 - 90000
            net_ipv4_neigh_default_gc_thresh3  = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_neigh_default_gc_thresh3", null)  # 1024 - 100000
            net_ipv4_tcp_fin_timeout           = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_fin_timeout", null)           # 5 - 120
            net_ipv4_tcp_keepalive_intvl       = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_keepalive_intvl", null)       # 10 - 75
            net_ipv4_tcp_keepalive_probes      = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_keepalive_probes", null)      # 1 - 15
            net_ipv4_tcp_keepalive_time        = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_keepalive_time", null)        # 30 - 432000
            net_ipv4_tcp_max_syn_backlog       = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_max_syn_backlog", null)       # 128 - 3240000
            net_ipv4_tcp_max_tw_buckets        = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_max_tw_buckets", null)        # 8000 - 1440000
            net_ipv4_tcp_tw_reuse              = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_ipv4_tcp_tw_reuse", null)              # bool
            net_netfilter_nf_conntrack_buckets = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_netfilter_nf_conntrack_buckets", null) # 65536 - 147456
            net_netfilter_nf_conntrack_max     = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "net_netfilter_nf_conntrack_max", null)     # 131072 - 1048576
            vm_max_map_count                   = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "vm_max_map_count", null)                   # 65530 - 262144
            vm_swappiness                      = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "vm_swappiness", null)                      # 0 - 100
            vm_vfs_cache_pressure              = lookup(var.default_node_pool_linux_os_config["sysctl_config"], "vm_vfs_cache_pressure", null)              # 0 - 100
          }
        }
        transparent_huge_page_defrag  = lookup(var.default_node_pool_linux_os_config, "transparent_huge_page_defrag", null)  # always, defer, defer+madvise, madvise, never
        transparent_huge_page_enabled = lookup(var.default_node_pool_linux_os_config, "transparent_huge_page_enabled", null) # always, madvise and never
      }
    }

    # Preview - Use public IP tags on node public IPs (https://learn.microsoft.com/en-us/azure/aks/use-node-public-ips#use-public-ip-tags-on-node-public-ips-preview)
    dynamic "node_network_profile" {
      for_each = var.default_node_pool_node_network_profile_enabled ? ["create"] : []
      content {
        node_public_ip_tags = var.default_node_pool_node_network_profile_node_public_ip_tags
      }
    }
  }

  # ------ Addons ------

  # Azure Policy
  azure_policy_enabled = var.addon_profile_azure_policy_enabled

  # Ingress Controller
  http_application_routing_enabled = var.addon_profile_http_application_routing_enabled

  # AGIC
  dynamic "ingress_application_gateway" { # Only AzureCNI, require additional nodepool if `only_critical_addons_enabled=true`
    for_each = var.addon_profile_ingress_application_gateway_enabled ? ["create"] : []
    content {
      gateway_id   = var.addon_profile_ingress_application_gateway_gateway_id
      gateway_name = var.addon_profile_ingress_application_gateway_gateway_name
      subnet_cidr  = var.addon_profile_ingress_application_gateway_subnet_cidr
      subnet_id    = var.addon_profile_ingress_application_gateway_subnet_id
    }
  }

  # Open Service Mesh
  open_service_mesh_enabled = var.addon_profile_open_service_mesh_enabled

  # RBAC integration
  role_based_access_control_enabled = var.rbac_enabled # default true
  # if true, Kubernetes RBAC and AKS-managed Azure AD integration must be enabled
  # https://docs.microsoft.com/en-us/azure/aks/managed-aad#disable-local-accounts
  local_account_disabled = var.local_account_disabled
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.rbac_aad_managed ? ["create"] : []
    content {
      managed                = var.rbac_aad_managed # deprecated and will be defaulted to true in v4.0
      tenant_id              = var.rbac_aad_tenant_id
      admin_group_object_ids = var.rbac_admin_group_object_ids
      azure_rbac_enabled     = true
    }
  }
  # dynamic "azure_active_directory_role_based_access_control" {
  #   for_each = var.rbac_aad_managed ? [] : ["create"]
  #   content {
  #     managed           = var.rbac_aad_managed # deprecated and will be defaulted to true in v4.0
  #     tenant_id         = var.rbac_aad_tenant_id
  #     client_app_id     = var.rbac_aad_client_app_id
  #     server_app_id     = var.rbac_aad_server_app_id
  #     server_app_secret = var.rbac_aad_server_app_secret
  #   }
  # }

  # OIDC Issuer
  # Preview - https://docs.microsoft.com/en-us/azure/aks/cluster-configuration#oidc-issuer-preview
  oidc_issuer_enabled = var.addon_profile_oidc_issuer_enabled # false

  # Workload Identity
  # Preview - https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster
  # require 
  # - oidc_issuer_enabled = true
  workload_identity_enabled = var.addon_profile_workload_identity_enabled # false

  # Workload Autoscaling
  dynamic "workload_autoscaler_profile" {
    for_each = var.addon_profile_workload_autoscaler_keda_enabled || var.addon_profile_workload_autoscaler_vpa_enabled ? ["create"] : []
    content {
      # KEDA
      # Preview - https://learn.microsoft.com/en-us/azure/aks/keda-about
      keda_enabled = var.addon_profile_workload_autoscaler_keda_enabled
      # VPA
      # Preview - https://learn.microsoft.com/en-us/azure/aks/vertical-pod-autoscaler
      vertical_pod_autoscaler_enabled = var.addon_profile_workload_autoscaler_vpa_enabled
    }
  }

  # Run Command
  # Preview - az aks command invoke (https://azure.microsoft.com/en-us/updates/public-preview-of-azure-kubernetes-service-aks-runcommand-feature/#:~:text=AKS%20run%20command%20allows%20you,laptop%20for%20a%20private%20cluster.)
  run_command_enabled = var.addon_profile_run_command_enabled # true

  # ACI Connector
  dynamic "aci_connector_linux" {
    for_each = var.addon_profile_aci_connector_linux_enabled ? ["create"] : []
    content {
      # Require this on subnet
      # | delegation {
      # |   name = "aciDelegation"
      # |   service_delegation {
      # |     name    = "Microsoft.ContainerInstance/containerGroups"
      # |     actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      # |   }
      # | }
      subnet_name = var.addon_profile_aci_connector_linux_subnet_name
    }
  }

  # Key Vault
  dynamic "key_vault_secrets_provider" {
    for_each = var.addon_profile_azure_keyvault_secrets_provider_enabled ? ["create"] : []
    content {
      secret_rotation_enabled  = var.addon_profile_azure_keyvault_secrets_provider_secret_rotation_enabled
      secret_rotation_interval = var.addon_profile_azure_keyvault_secrets_provider_secret_rotation_interval
    }
  }

  # OMS Agent 
  dynamic "oms_agent" {
    for_each = var.addon_profile_oms_agent_enabled ? ["create"] : []
    content {
      log_analytics_workspace_id      = var.addon_profile_oms_agent_log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = var.addon_profile_oms_agent_msi_auth_for_monitoring_enabled
    }
  }

  # Microsoft Defender for Containers
  # Preview - must be enable https://docs.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-enable
  dynamic "microsoft_defender" {
    for_each = var.addon_profile_microsoft_defender_enabled ? ["create"] : []
    content {
      log_analytics_workspace_id = var.addon_profile_microsoft_defender_log_analytics_workspace_id
    }
  }

  # Managed nginx ingress with the application routing add-on
  # Preview - https://learn.microsoft.com/en-us/azure/aks/app-routing?tabs=without-osm
  dynamic "web_app_routing" {
    for_each = var.addon_profile_web_app_routing_enabled ? ["create"] : []
    content {
      dns_zone_ids = var.addon_profile_web_app_routing_dns_zone_id
    }
  }

  # Istio-based service mesh add-on https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon
  dynamic "service_mesh_profile" {
    for_each = var.addon_profile_service_mesh_profile_enabled ? ["create"] : []
    content {
      mode                             = var.addon_profile_service_mesh_profile_mode
      internal_ingress_gateway_enabled = var.addon_profile_service_mesh_profile_internal_ingress_gateway_enabled
      external_ingress_gateway_enabled = var.addon_profile_service_mesh_profile_external_ingress_gateway_enabled

      # dynamic "certificate_authority" {
      #   for_each = var.addon_profile_web_app_routing_enabled ? ["create"] : []
      #   content {
      #     key_vault_id = var.addon_profile_service_mesh_profile_certificate_authority_key_vault_id
      #     root_cert_object_name = var.addon_profile_service_mesh_profile_certificate_authority_root_cert_object_name
      #     cert_chain_object_name  = var.addon_profile_service_mesh_profile_certificate_authority_cert_chain_object_name
      #     cert_object_name = var.addon_profile_service_mesh_profile_certificate_authority_cert_object_name
      #     key_object_name = var.addon_profile_service_mesh_profile_certificate_authority_key_object_name
      #   }
      # }

      # revisions                        = var.addon_profile_service_mesh_profile_revisions
    }
  }


  # ------ Others ------

  dynamic "auto_scaler_profile" {
    for_each = length(var.auto_scaler_profile) > 0 ? ["create"] : []
    content {
      balance_similar_node_groups      = lookup(var.auto_scaler_profile, "balance_similar_node_groups", null)
      expander                         = lookup(var.auto_scaler_profile, "expander", null)
      max_graceful_termination_sec     = lookup(var.auto_scaler_profile, "max_graceful_termination_sec", null)
      max_node_provisioning_time       = lookup(var.auto_scaler_profile, "max_node_provisioning_time", null)
      max_unready_nodes                = lookup(var.auto_scaler_profile, "max_unready_nodes", null)
      max_unready_percentage           = lookup(var.auto_scaler_profile, "max_unready_percentage", null)
      new_pod_scale_up_delay           = lookup(var.auto_scaler_profile, "new_pod_scale_up_delay", null)
      scan_interval                    = lookup(var.auto_scaler_profile, "scan_interval", null)
      scale_down_delay_after_add       = lookup(var.auto_scaler_profile, "scale_down_delay_after_add", null)
      scale_down_delay_after_delete    = lookup(var.auto_scaler_profile, "scale_down_delay_after_delete", null)
      scale_down_delay_after_failure   = lookup(var.auto_scaler_profile, "scale_down_delay_after_failure", null)
      scale_down_unneeded              = lookup(var.auto_scaler_profile, "scale_down_unneeded", null)
      scale_down_unready               = lookup(var.auto_scaler_profile, "scale_down_unready", null)
      scale_down_utilization_threshold = lookup(var.auto_scaler_profile, "scale_down_utilization_threshold", null)
      empty_bulk_delete_max            = lookup(var.auto_scaler_profile, "empty_bulk_delete_max", null)
      skip_nodes_with_local_storage    = lookup(var.auto_scaler_profile, "skip_nodes_with_local_storage", null)
      skip_nodes_with_system_pods      = lookup(var.auto_scaler_profile, "skip_nodes_with_system_pods", null)
    }
  }

  network_profile {
    network_plugin      = var.network_profile_network_plugin      # azure, kubenet, none | for azure, vnet_subnet_id and pod_cidr must be set.
    network_plugin_mode = var.network_profile_network_plugin_mode # null, Overlay (require network_plugin=azure)
    network_policy      = var.network_profile_network_policy      # calico, azure, cilium
    dns_service_ip      = var.network_profile_dns_service_ip
    network_data_plane  = var.network_profile_network_data_plane # azure, cilium
    docker_bridge_cidr  = var.network_profile_docker_bridge_cidr # Deprecated and will be removed in version 4.0 of the provider. 
    service_cidr        = var.network_profile_service_cidr
    service_cidrs       = var.network_profile_service_cidrs # for Preview - Dual stack e.g.  ["10.1.1.0/24", "2002::1234:abcd:ffff:c0a8:101/120"]
    pod_cidr            = var.network_profile_network_plugin == "kubenet" || var.network_profile_network_plugin_mode == "overlay " ? var.network_profile_pod_cidr : null
    pod_cidrs           = var.network_profile_pod_cidrs         # for Preview - Dual stack e.g.  ["10.1.1.0/24", "2002::1234:abcd:ffff:c0a8:101/120"]
    outbound_type       = var.network_profile_outbound_type     # loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway
    ip_versions         = var.network_profile_ip_versions       # Preview - Dual stack ["IPv4", "IPv6"] https://docs.microsoft.com/en-us/azure/aks/configure-kubenet-dual-stack?tabs=azure-cli%2Ckubectl#register-the-aks-enabledualstack-preview-feature
    load_balancer_sku   = var.network_profile_load_balancer_sku # "standard" # basic, standard
    dynamic "load_balancer_profile" {
      for_each = var.network_profile_load_balancer_sku == "standard" && var.network_profile_outbound_type == "loadBalancer" ? ["create"] : []
      content {
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes     # null # 4 - 120
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count   # null # 1 - 100
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count # null # 1 - 100 (0=single stack, 1=dual stack)
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids     # [] # [] = use managed_outbound_ip
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids      # [] # [] = use managed_outbound_ip
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated    # null
      }
    }
    dynamic "nat_gateway_profile" {
      for_each = contains(["managedNATGateway", "userAssignedNATGateway"], var.network_profile_outbound_type) ? ["create"] : []
      content {
        idle_timeout_in_minutes   = var.nat_gateway_profile_idle_timeout_in_minutes   # 4 # 4 - 120
        managed_outbound_ip_count = var.nat_gateway_profile_managed_outbound_ip_count # 1 - 100
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "SystemAssigned" ? ["id"] : []
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "ManagedIdentity" ? ["id"] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.identity_id, ]
    }
  }

  dynamic "service_principal" {
    for_each = var.identity_type == "ServicePrincipal" ? ["id"] : []
    content {
      client_id     = var.identity_app_id
      client_secret = var.identity_app_secret
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile_enable ? ["profile"] : []
    content {
      admin_username = var.windows_profile_admin_username
      admin_password = var.windows_profile_admin_password
      license        = "Windows_Server"
      dynamic "gmsa" {
        for_each = var.windows_profile_gmsa_dns_server != null && var.windows_profile_gmsa_root_domain != null ? ["create"] : []
        content {
          dns_server  = var.windows_profile_gmsa_dns_server
          root_domain = var.windows_profile_gmsa_root_domain
        }
      }
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile_enable ? ["profile"] : []
    content {
      admin_username = var.linux_profile_admin_username
      ssh_key {
        key_data = replace(var.linux_profile_public_ssh_key == "" ? module.ssh-key.public_ssh_key : var.linux_profile_public_ssh_key, "\n", "")
      }
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window_allowed || var.maintenance_window_not_allowed ? ["create"] : []
    content {
      dynamic "allowed" {
        for_each = var.maintenance_window_allowed ? ["create"] : []
        content {
          day   = var.maintenance_window_allowed_day
          hours = var.maintenance_window_allowed_hours
        }
      }
      dynamic "not_allowed" {
        for_each = var.maintenance_window_not_allowed ? ["create"] : []
        content {
          start = var.maintenance_window_not_allowed_start
          end   = var.maintenance_window_not_allowed_end
        }
      }
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade_enabled ? ["create"] : []
    content {
      frequency   = var.maintenance_window_auto_upgrade_frequency
      interval    = var.maintenance_window_auto_upgrade_interval
      duration    = var.maintenance_window_auto_upgrade_duration
      day_of_week = var.maintenance_window_auto_upgrade_day_of_week
      week_index  = var.maintenance_window_auto_upgrade_week_index
      start_date  = var.maintenance_window_auto_upgrade_start_date
      start_time  = var.maintenance_window_auto_upgrade_start_time
      utc_offset  = var.maintenance_window_auto_upgrade_utc_offset
      dynamic "not_allowed" {
        for_each = var.maintenance_window_auto_upgrade_not_allowed ? ["create"] : []
        content {
          start = var.maintenance_window_auto_upgrade_not_allowed_start
          end   = var.maintenance_window_auto_upgrade_not_allowed_end
        }
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os_enabled ? ["create"] : []
    content {
      frequency   = var.maintenance_window_node_os_frequency
      interval    = var.maintenance_window_node_os_interval
      duration    = var.maintenance_window_node_os_duration
      day_of_week = var.maintenance_window_node_os_day_of_week
      week_index  = var.maintenance_window_node_os_week_index
      start_date  = var.maintenance_window_node_os_start_date
      start_time  = var.maintenance_window_node_os_start_time
      utc_offset  = var.maintenance_window_node_os_utc_offset
      dynamic "not_allowed" {
        for_each = var.maintenance_window_node_os_not_allowed ? ["create"] : []
        content {
          start = var.maintenance_window_node_os_not_allowed_start
          end   = var.maintenance_window_node_os_not_allowed_end
        }
      }
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config_enabled ? ["create"] : []
    content {
      http_proxy  = var.http_proxy_config_http_proxy
      https_proxy = var.http_proxy_config_https_proxy
      no_proxy    = var.default_node_pool_vnet_subnet_id == null ? (join(",", var.http_proxy_config_no_proxys) == "" ? null : join(",", var.http_proxy_config_no_proxys)) : join(",", concat([var.default_node_pool_vnet_subnet_id, ], var.http_proxy_config_no_proxys))
      trusted_ca  = var.http_proxy_config_trusted_ca
    }
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity_enabled ? ["create"] : []
    content {
      client_id                 = var.kubelet_identity_client_id
      object_id                 = var.kubelet_identity_object_id
      user_assigned_identity_id = var.kubelet_identity_user_assigned_identity_id
    }
  }

  storage_profile {
    blob_driver_enabled         = var.storage_profile_blob_driver_enabled
    disk_driver_enabled         = var.storage_profile_disk_driver_enabled
    file_driver_enabled         = var.storage_profile_file_driver_enabled
    snapshot_controller_enabled = var.storage_profile_snapshot_controller_enabled
  }

  # Preview - Prometheus Metric Enable
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics_enabled ? ["create"] : []
    content {
      annotations_allowed = var.monitor_metrics_annotations_allowed
      labels_allowed      = var.monitor_metrics_labels_allowed
    }
  }

  # Enable encryption at rest in etcd using Azure Key Vault.
  dynamic "key_management_service" {
    for_each = var.kms_enabled ? ["create"] : []
    content {
      key_vault_key_id         = var.kms_key_vault_key_id
      key_vault_network_access = var.kms_key_vault_network_access
    }
  }

  # Enable Intel SGX based confidential computing nodes
  # REF: https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-nodes-aks-overview
  dynamic "confidential_computing" {
    for_each = var.sgx_quote_helper_enabled ? ["create"] : []
    content {
      sgx_quote_helper_enabled = var.sgx_quote_helper_enabled
    }
  }



}

# ------ Node Pools ------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = var.node_pools

  name                     = each.key
  tags                     = merge(each.value.tags, var.tags)
  mode                     = lookup(each.value, "mode", "User")
  kubernetes_cluster_id    = azurerm_kubernetes_cluster.main.id
  orchestrator_version     = lookup(each.value, "orchestrator_version", null) == null ? var.kubernetes_version : each.value.orchestrator_version
  workload_runtime         = lookup(each.value, "workload_runtime", "OCIContainer")
  os_type                  = lookup(each.value, "os_type", null) == null ? "Linux" : each.value.os_type
  os_sku                   = lookup(each.value, "os_sku", null)
  os_disk_size_gb          = lookup(each.value, "os_disk_size_gb", null) == null ? 50 : each.value.os_disk_size_gb
  os_disk_type             = lookup(each.value, "os_disk_type", null) == null ? "Managed" : each.value.os_disk_type
  vm_size                  = lookup(each.value, "vm_size", null) == null ? "Standard_DS2_v2" : each.value.vm_size
  vnet_subnet_id           = lookup(each.value, "vnet_subnet_id", null) == null ? var.default_node_pool_vnet_subnet_id : each.value.vnet_subnet_id
  pod_subnet_id            = var.network_profile_network_plugin == "azure" ? lookup(each.value, "pod_subnet_id", null) : null
  zones                    = lookup(each.value, "availability_zones", null)
  max_pods                 = lookup(each.value, "max_pods", null)
  enable_host_encryption   = lookup(each.value, "enable_host_encryption", false) # Azure RM v4 change to host_encryption_enabled
  enable_node_public_ip    = lookup(each.value, "enable_node_public_ip", false)  # Azure RM v4 change to node_public_ip_enabled
  node_public_ip_prefix_id = lookup(each.value, "node_public_ip_prefix_id", null)
  ultra_ssd_enabled        = lookup(each.value, "ultra_ssd_enabled", false)
  fips_enabled             = lookup(each.value, "fips_enabled", false)
  host_group_id            = lookup(each.value, "host_group_id", null)
  snapshot_id              = lookup(each.value, "snapshot_id", null)

  enable_auto_scaling = lookup(each.value, "enable_auto_scaling", true) # Azure RM v4 change to auto_scaling_enabled
  scale_down_mode     = lookup(each.value, "scale_down_mode", "Delete")
  max_count           = lookup(each.value, "max_count", 10)
  min_count           = lookup(each.value, "min_count", 1)
  node_count          = lookup(each.value, "node_count", 1)

  priority        = lookup(each.value, "priority", "Regular")
  spot_max_price  = lookup(each.value, "priority", "Regular") == "Spot" ? lookup(each.value, "spot_max_price", null) : null
  eviction_policy = lookup(each.value, "priority", "Regular") == "Spot" ? "Delete" : lookup(each.value, "eviction_policy", null)
  node_labels     = lookup(each.value, "priority", "Regular") == "Spot" ? merge({ "kubernetes.azure.com/scalesetpriority" : "spot" }, each.value.node_labels) : lookup(each.value, "node_labels", null)
  node_taints     = lookup(each.value, "priority", "Regular") == "Spot" ? concat(["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"], each.value.node_taints) : each.value.node_taints

  proximity_placement_group_id  = lookup(each.value, "proximity_placement_group_id", null)
  capacity_reservation_group_id = lookup(each.value, "capacity_reservation_group_id", null)

  dynamic "upgrade_settings" {
    for_each = lookup(each.value, "upgrade_settings_max_surge", null) != null ? ["create"] : []
    content {
      max_surge = each.value.upgrade_settings_max_surge
    }
  }

  kubelet_disk_type = lookup(each.value, "kubelet_disk_type", null)
  dynamic "kubelet_config" {
    for_each = length(lookup(each.value, "kubelet_config", toset([]))) > 0 ? ["create"] : []
    content {
      allowed_unsafe_sysctls    = lookup(each.value.kubelet_confg, "allowed_unsafe_sysctls", null)
      container_log_max_line    = lookup(each.value.kubelet_confg, "container_log_max_line", null)
      container_log_max_size_mb = lookup(each.value.kubelet_confg, "container_log_max_size_mb", null)
      cpu_cfs_quota_enabled     = lookup(each.value.kubelet_confg, "cpu_cfs_quota_enabled", null)
      cpu_cfs_quota_period      = lookup(each.value.kubelet_confg, "cpu_cfs_quota_period", null)
      cpu_manager_policy        = lookup(each.value.kubelet_confg, "cpu_manager_policy", null)
      image_gc_high_threshold   = lookup(each.value.kubelet_confg, "image_gc_high_threshold", null)
      image_gc_low_threshold    = lookup(each.value.kubelet_confg, "image_gc_low_threshold", null)
      pod_max_pid               = lookup(each.value.kubelet_confg, "pod_max_pid", null)
      topology_manager_policy   = lookup(each.value.kubelet_confg, "topology_manager_policy", null)
    }
  }

  dynamic "linux_os_config" {
    for_each = length(lookup(each.value, "linux_os_config", toset([]))) > 0 ? ["create"] : []
    content {
      swap_file_size_mb             = lookup(each.value.linux_os_config, "swap_file_size_mb", null)
      transparent_huge_page_defrag  = lookup(each.value.linux_os_config, "transparent_huge_page_defrag", null)
      transparent_huge_page_enabled = lookup(each.value.linux_os_config, "transparent_huge_page_enabled", null)
      dynamic "sysctl_config" {
        for_each = length(lookup(each.value.linux_os_config, "sysctl_config", {})) > 0 ? ["create"] : []
        content {
          fs_aio_max_nr                      = lookup(each.value.linux_os_config["sysctl_config"], "fs_aio_max_nr", null)                      # 65536 - 6553500
          fs_file_max                        = lookup(each.value.linux_os_config["sysctl_config"], "fs_file_max", null)                        # 8192 - 12000500
          fs_inotify_max_user_watches        = lookup(each.value.linux_os_config["sysctl_config"], "fs_inotify_max_user_watches", null)        # 781250 - 2097152
          fs_nr_open                         = lookup(each.value.linux_os_config["sysctl_config"], "fs_nr_open", null)                         # 8192 - 20000500
          kernel_threads_max                 = lookup(each.value.linux_os_config["sysctl_config"], "kernel_threads_max", null)                 # 20 - 513785
          net_core_netdev_max_backlog        = lookup(each.value.linux_os_config["sysctl_config"], "net_core_netdev_max_backlog", null)        # 1000 - 3240000
          net_core_optmem_max                = lookup(each.value.linux_os_config["sysctl_config"], "net_core_optmem_max", null)                # 20480 - 4194304
          net_core_rmem_default              = lookup(each.value.linux_os_config["sysctl_config"], "net_core_optmem_max", null)                # 212992 - 134217728
          net_core_rmem_max                  = lookup(each.value.linux_os_config["sysctl_config"], "net_core_rmem_max", null)                  # 212992 - 134217728
          net_core_somaxconn                 = lookup(each.value.linux_os_config["sysctl_config"], "net_core_somaxconn", null)                 # 4096 - 3240000
          net_core_wmem_default              = lookup(each.value.linux_os_config["sysctl_config"], "net_core_wmem_default", null)              # 212992 - 134217728
          net_core_wmem_max                  = lookup(each.value.linux_os_config["sysctl_config"], "net_core_wmem_max", null)                  # 212992 - 134217728
          net_ipv4_ip_local_port_range_max   = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_ip_local_port_range_max", null)   # 1024 - 60999
          net_ipv4_ip_local_port_range_min   = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_ip_local_port_range_min", null)   # 1024 - 60999
          net_ipv4_neigh_default_gc_thresh1  = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_neigh_default_gc_thresh1", null)  # 128 - 80000
          net_ipv4_neigh_default_gc_thresh2  = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_neigh_default_gc_thresh2", null)  # 512 - 90000
          net_ipv4_neigh_default_gc_thresh3  = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_neigh_default_gc_thresh3", null)  # 1024 - 100000
          net_ipv4_tcp_fin_timeout           = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_fin_timeout", null)           # 5 - 120
          net_ipv4_tcp_keepalive_intvl       = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_keepalive_intvl", null)       # 10 - 75
          net_ipv4_tcp_keepalive_probes      = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_keepalive_probes", null)      # 1 - 15
          net_ipv4_tcp_keepalive_time        = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_keepalive_time", null)        # 30 - 432000
          net_ipv4_tcp_max_syn_backlog       = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_max_syn_backlog", null)       # 128 - 3240000
          net_ipv4_tcp_max_tw_buckets        = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_max_tw_buckets", null)        # 8000 - 1440000
          net_ipv4_tcp_tw_reuse              = lookup(each.value.linux_os_config["sysctl_config"], "net_ipv4_tcp_tw_reuse", null)              # bool
          net_netfilter_nf_conntrack_buckets = lookup(each.value.linux_os_config["sysctl_config"], "net_netfilter_nf_conntrack_buckets", null) # 65536 - 147456
          net_netfilter_nf_conntrack_max     = lookup(each.value.linux_os_config["sysctl_config"], "net_netfilter_nf_conntrack_max", null)     # 131072 - 1048576
          vm_max_map_count                   = lookup(each.value.linux_os_config["sysctl_config"], "vm_max_map_count", null)                   # 65530 - 262144
          vm_swappiness                      = lookup(each.value.linux_os_config["sysctl_config"], "vm_swappiness", null)                      # 0 - 100
          vm_vfs_cache_pressure              = lookup(each.value.linux_os_config["sysctl_config"], "vm_vfs_cache_pressure", null)              # 0 - 100
        }
      }
    }
  }

  dynamic "windows_profile" {
    for_each = length(lookup(each.value, "windows_profile", toset([]))) > 0 ? ["create"] : []
    content {
      outbound_nat_enabled = lookup(each.value.windows_profile, "outbound_nat_enabled", true)
    }
  }

  # Preview - Use public IP tags on node public IPs (https://learn.microsoft.com/en-us/azure/aks/use-node-public-ips#use-public-ip-tags-on-node-public-ips-preview)
  dynamic "node_network_profile" {
    for_each = length(lookup(each.value, "node_network_profile", toset([]))) > 0 ? ["create"] : []
    content {
      node_public_ip_tags = lookup(each.value.node_network_profile, "node_public_ip_tags", {})
    }
  }

}

# ------ Attach ACR ----------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_role_assignment" "attach_acr" {
  count = var.enable_attach_acr ? 1 : 0

  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# ------ Attach Key Vault ----------------------------------------------------------------------------------------------------------------------------------------------------

# --- Currently Avaiable in Doc ---
resource "azurerm_key_vault_access_policy" "aks_secret_identity" {
  count = var.addon_profile_azure_keyvault_secrets_provider_secret_rotation_enabled && var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_enabled ? 1 : 0

  key_vault_id = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_kubernetes_cluster.main.key_vault_secrets_provider.0.secret_identity.0.object_id

  certificate_permissions = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_cert_perms
  key_permissions         = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_key_perms
  secret_permissions      = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_secret_perms
}

# --- Previously Available in Doc ---
resource "azurerm_key_vault_access_policy" "aks_kubelet_identity" {
  count = var.addon_profile_azure_keyvault_secrets_provider_secret_rotation_enabled && var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_enabled ? 1 : 0

  key_vault_id = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_kubernetes_cluster.main.kubelet_identity.0.object_id

  certificate_permissions = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_cert_perms
  key_permissions         = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_key_perms
  secret_permissions      = var.addon_profile_azure_keyvault_secrets_provider_attach_keyvault_secret_perms
}

# ------ Log Analytics Solution ----------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_log_analytics_solution" "main" {
  count = var.addon_profile_oms_agent_enabled ? 1 : 0

  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.addon_profile_oms_agent_log_analytics_workspace_id
  workspace_name        = split("/", var.addon_profile_oms_agent_log_analytics_workspace_id).8

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "aks" {
  count = var.addon_profile_oms_agent_enabled && var.addon_profile_oms_agent_role_assignment_enabled ? 1 : 0

  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.main.oms_agent[0].oms_agent_identity[0].object_id
}

# ------ Diagnostic Setting ----------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
  count = length(var.diagnostic_settings)

  name               = "diag-${var.cluster_name}-${var.diagnostic_settings[count.index].suffix_name}"
  target_resource_id = azurerm_kubernetes_cluster.main.id

  storage_account_id             = lookup(var.diagnostic_settings[count.index], "storage_account_id", null)
  log_analytics_workspace_id     = lookup(var.diagnostic_settings[count.index], "log_analytics_workspace_id", null)
  log_analytics_destination_type = lookup(var.diagnostic_settings[count.index], "log_analytics_destination_type", "Dedicated")
  eventhub_authorization_rule_id = lookup(var.diagnostic_settings[count.index], "eventhub_authorization_rule_id", null)
  eventhub_name                  = lookup(var.diagnostic_settings[count.index], "eventhub_name", null)
  partner_solution_id            = lookup(var.diagnostic_settings[count.index], "partner_solution_id", null)

  # log - will be remove on AzureRM 4.0
  dynamic "log" {
    for_each = lookup(var.diagnostic_settings[count.index], "log", toset([]))

    content {
      category = log.value
      enabled  = true
    }
  }

  # enabled_log
  dynamic "enabled_log" {
    for_each = lookup(var.diagnostic_settings[count.index], "enabled_logs", toset([]))

    content {
      category = enabled_log.value
    }
  }

  # enabled_category
  dynamic "enabled_log" {
    for_each = lookup(var.diagnostic_settings[count.index], "enabled_categories", toset([]))

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.diagnostic_settings[count.index], "metric", toset([]))

    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [log, enabled_log, metric, log_analytics_destination_type]
  }
}
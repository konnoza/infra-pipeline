output "client_key" {
  value = try(azurerm_kubernetes_cluster.main.kube_config[0].client_key, null)
}

output "client_certificate" {
  value = try(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate, null)
}

output "cluster_ca_certificate" {
  value = try(azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate, null)
}

output "host" {
  value = try(azurerm_kubernetes_cluster.main.kube_config[0].host, null)
}

output "username" {
  value = try(azurerm_kubernetes_cluster.main.kube_config[0].username, null)
}

output "password" {
  value = try(azurerm_kubernetes_cluster.main.kube_config[0].password, null)
}

output "node_resource_group_name" {
  value = azurerm_kubernetes_cluster.main.node_resource_group
}

output "node_resource_group_id" {
  value = azurerm_kubernetes_cluster.main.node_resource_group_id
}

output "location" {
  value = azurerm_kubernetes_cluster.main.location
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "kube_config_raw" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
}

output "http_application_routing_zone_name" {
  value = azurerm_kubernetes_cluster.main.http_application_routing_zone_name
}

output "system_assigned_identity" {
  value = azurerm_kubernetes_cluster.main.identity
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "secret_identity" {
  value = try(azurerm_kubernetes_cluster.main.key_vault_secrets_provider.0.secret_identity.0, null)
}

output "oms_agent_identity" {
  value = try(azurerm_kubernetes_cluster.main.oms_agent.0.oms_agent_identity.0, null)
}

output "admin_client_key" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.client_key : ""
}

output "admin_client_certificate" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.client_certificate : ""
}

output "admin_cluster_ca_certificate" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.cluster_ca_certificate : ""
}

output "admin_host" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.host : ""
}

output "admin_username" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.username : ""
}

output "admin_password" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.password : ""
}

output "main" {
  value = azurerm_kubernetes_cluster.main
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.main.oidc_issuer_url
}
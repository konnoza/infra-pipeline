# --- azurerm_storage_account ---

output "storage_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.main.id
}

output "storage_identity" {
  description = "The identity of the storage"
  value       = azurerm_storage_account.main.identity
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.main.primary_access_key
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account."
  value       = azurerm_storage_account.main.secondary_access_key
}

output "azure_file_url" {
  description = "List of Azure File URL"
  value       = [for x in azurerm_storage_share.main : x.url]
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location."
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location."
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_endpoint
}

output "primary_location" {
  description = "The primary location of the storage account."
  value       = azurerm_storage_account.main.primary_location
}

output "secondary_location" {
  description = "The secondary location of the storage account."
  value       = azurerm_storage_account.main.secondary_location
}


output "primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_host
}

output "secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_blob_endpoint
}

output "secondary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_blob_host
}

output "primary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the primary location."
  value       = azurerm_storage_account.main.primary_queue_host
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_queue_endpoint
}

output "secondary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_queue_host
}

output "primary_table_host" {
  description = "The hostname with port if applicable for table storage in the primary location."
  value       = azurerm_storage_account.main.primary_table_host
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_table_endpoint
}

output "secondary_table_host" {
  description = "The hostname with port if applicable for table storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_table_host
}

output "primary_file_host" {
  description = "The hostname with port if applicable for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_host
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_file_endpoint
}

output "secondary_file_host" {
  description = "The hostname with port if applicable for file storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_file_host
}

output "primary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_host
}

output "secondary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_dfs_endpoint
}

output "secondary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_dfs_host
}

output "primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_host
}

output "secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_web_endpoint
}

output "secondary_web_host" {
  description = "The hostname with port if applicable for web storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_web_host
}

output "primary_connection_string" {
  description = "The connection string associated with the primary location."
  value       = azurerm_storage_account.main.primary_connection_string
}

output "secondary_connection_string" {
  description = "The connection string associated with the secondary location."
  value       = azurerm_storage_account.main.secondary_connection_string
}

output "primary_blob_connection_string" {
  description = "The connection string associated with the primary blob location."
  value       = azurerm_storage_account.main.primary_blob_connection_string
}

output "secondary_blob_connection_string" {
  description = "The connection string associated with the secondary blob location."
  value       = azurerm_storage_account.main.secondary_blob_connection_string
}

# --- azurerm_storage_share ---

output "azure_share_id" {
  description = "List of Azure Blob ID the File Share"
  value       = azurerm_storage_share.main[*].id
}

output "azure_share_resource_manager_id" {
  description = "List of Resource Manager ID of the File Share"
  value       = azurerm_storage_share.main[*].resource_manager_id
}

output "azure_share_url" {
  description = "List of URL of the File Share"
  value       = azurerm_storage_share.main[*].url
}

# --- azurerm_storage_container ---

output "azure_blob_id" {
  description = "List of Azure Blob ID"
  value       = azurerm_storage_container.main[*].id
}

output "azure_blob_has_immutability_policy" {
  description = "List of Immutability Policy configured on this Storage Container."
  value       = azurerm_storage_container.main[*].has_immutability_policy
}

output "azure_blob_has_legal_hold" {
  description = "List of Legal Hold configured on this Storage Container."
  value       = azurerm_storage_container.main[*].has_legal_hold
}

output "azure_blob_resource_manager_id" {
  description = "List of Resource Manager ID of this Storage Container."
  value       = azurerm_storage_container.main[*].resource_manager_id
}

# --- azurerm_storage_table ---

output "azure_table_id" {
  description = "List of ID of the Table within the Storage Account."
  value       = [for table in azurerm_storage_table.main : table.id]
}

# ---- azurerm_storage_queue --- 

output "azure_queue_id" {
  description = "List of Azure Queue ID"
  value       = azurerm_storage_queue.main[*].id
}
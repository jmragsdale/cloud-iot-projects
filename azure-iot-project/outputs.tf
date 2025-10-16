output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.rg.name
}

output "iothub_name" {
  description = "IoT Hub name"
  value       = azurerm_iothub.iothub.name
}

output "iothub_hostname" {
  description = "IoT Hub hostname"
  value       = azurerm_iothub.iothub.hostname
}

output "device_id" {
  description = "IoT device ID"
  value       = azurerm_iothub_device.device.name
}

output "device_connection_string" {
  description = "Device connection string"
  value       = "HostName=${azurerm_iothub.iothub.hostname};DeviceId=${azurerm_iothub_device.device.name};SharedAccessKey=${azurerm_iothub_device.device.primary_key}"
  sensitive   = true
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint"
  value       = azurerm_cosmosdb_account.db.endpoint
}

output "cosmos_db_database" {
  description = "Cosmos DB database name"
  value       = azurerm_cosmosdb_sql_database.database.name
}

output "cosmos_db_container" {
  description = "Cosmos DB container name"
  value       = azurerm_cosmosdb_sql_container.container.name
}

output "function_app_name" {
  description = "Function App name"
  value       = azurerm_linux_function_app.function.name
}

output "function_app_url" {
  description = "Function App URL"
  value       = "https://${azurerm_linux_function_app.function.default_hostname}"
}

output "application_insights_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.insights.instrumentation_key
  sensitive   = true
}

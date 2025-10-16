terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"
  location = var.azure_region
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Storage Account (required for Function App)
resource "azurerm_storage_account" "storage" {
  name                     = "${var.project_name}stor${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# IoT Hub
resource "azurerm_iothub" "iothub" {
  name                = "${var.project_name}-iothub-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    name     = "F1"  # Free tier
    capacity = 1
  }

  tags = {
    Environment = var.environment
  }
}

# IoT Hub Device
resource "azurerm_iothub_device" "device" {
  name           = "temperature-sensor-001"
  iothub_name    = azurerm_iothub.iothub.name
  resource_group = azurerm_resource_group.rg.name
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "db" {
  name                = "${var.project_name}-cosmos-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

# Cosmos DB Database
resource "azurerm_cosmosdb_sql_database" "database" {
  name                = "iot-data"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
}

# Cosmos DB Container
resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "sensor-readings"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_sql_database.database.name
  partition_key_paths = ["/deviceId"]
}

# App Service Plan for Function App
resource "azurerm_service_plan" "plan" {
  name                = "${var.project_name}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption plan
}

# Function App
resource "azurerm_linux_function_app" "function" {
  name                = "${var.project_name}-func-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsStorage"           = azurerm_storage_account.storage.primary_connection_string
    "COSMOS_DB_CONNECTION_STRING"   = azurerm_cosmosdb_account.db.primary_sql_connection_string
    "COSMOS_DB_DATABASE"            = azurerm_cosmosdb_sql_database.database.name
    "COSMOS_DB_CONTAINER"           = azurerm_cosmosdb_sql_container.container.name
    "IOTHUB_CONNECTION_STRING"      = azurerm_iothub.iothub.shared_access_policy[0].primary_connection_string
    "TEMP_THRESHOLD"                = var.temperature_threshold
    "ALERT_EMAIL"                   = var.alert_email
  }

  identity {
    type = "SystemAssigned"
  }
}

# Event Hub Namespace (for IoT Hub routing)
resource "azurerm_eventhub_namespace" "eventhub_ns" {
  name                = "${var.project_name}-evhns-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  capacity            = 1
}

# Event Hub
resource "azurerm_eventhub" "eventhub" {
  name                = "iot-messages"
  namespace_name      = azurerm_eventhub_namespace.eventhub_ns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

# IoT Hub to Event Hub Route
resource "azurerm_iothub_route" "route" {
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iothub.name
  name                = "EventHubRoute"
  source              = "DeviceMessages"
  condition           = "true"
  endpoint_names      = [azurerm_iothub_endpoint_eventhub.endpoint.name]
  enabled             = true
}

# IoT Hub Endpoint for Event Hub
resource "azurerm_iothub_endpoint_eventhub" "endpoint" {
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iothub.name
  name                = "EventHubEndpoint"
  connection_string   = azurerm_eventhub_namespace.eventhub_ns.default_primary_connection_string
  entity_path         = azurerm_eventhub.eventhub.name
}

# Application Insights
resource "azurerm_application_insights" "insights" {
  name                = "${var.project_name}-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

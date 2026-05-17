terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.72.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}

variable "application-name" {
  type    = string
  default = "whoami API"
}

variable "azure-tenant-id" {
  type      = string
  sensitive = true
}

variable "database-administrator-username" {
  type      = string
  sensitive = true
}

variable "database-administrator-password" {
  type      = string
  sensitive = true
}

resource "azurerm_resource_group" "resource-group-whoami-api" {
  name     = "whoami-api"
  location = "uksouth"
  tags = {
    application = var.application-name
  }
}

resource "azurerm_key_vault" "key-vault-whoami-api" {
  name                = "whoami-keyvault"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  sku_name                      = "standard"
  tenant_id                     = var.azure-tenant-id
  public_network_access_enabled = true
  rbac_authorization_enabled    = true
}

resource "azurerm_mssql_server" "mssql-server-whoami-api" {
  name                = "whoami-mssql-server"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  version                       = "12.0"
  public_network_access_enabled = true

  administrator_login          = var.database-administrator-username
  administrator_login_password = var.database-administrator-password
}

resource "azurerm_mssql_database" "mssql-database-whoami-api" {
  name      = "whoami-mssql-database"
  server_id = azurerm_mssql_server.mssql-server-whoami-api.id
  tags = {
    application = var.application-name
  }
  sku_name                       = "Basic"
  storage_account_type           = "Local"
  maintenance_configuration_name = "SQL_Default"
  collation                      = "SQL_Latin1_General_CP1_CI_AS"
  geo_backup_enabled             = true
  max_size_gb                    = 2
  short_term_retention_policy {
    backup_interval_in_hours = 24
    retention_days           = 7
  }
}

resource "azurerm_mssql_firewall_rule" "sql-firewall-rule-whoami-api-allow-azure-service-access" {
  name             = "AllowAzureServiceAccess"
  server_id        = azurerm_mssql_server.mssql-server-whoami-api.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_storage_account" "storage-account-whoami-api" {
  name                = "whoamistorage"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  access_tier                     = "Hot"
  account_kind                    = "StorageV2"
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  https_traffic_only_enabled      = true
  public_network_access_enabled   = true
}

resource "azurerm_service_plan" "service-plan-whoami-api" {
  name                = "whoami-service-plan"
  location            = "ukwest" # Moved to ukwest due to SKU quota / availability limits in uksouth
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  os_type                = "Linux"
  sku_name               = "B1"
  worker_count           = 1
  zone_balancing_enabled = false
}

resource "azurerm_linux_web_app" "linux-web-app-whoami-api" {
  name                = "whoami-linux-web-app"
  location            = "ukwest" # Moved to ukwest due to SKU quota / availability limits in uksouth
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  service_plan_id               = azurerm_service_plan.service-plan-whoami-api.id
  https_only                    = true
  public_network_access_enabled = true
  site_config {
    worker_count = 1
    always_on    = false
    application_stack {
      dotnet_version = "10.0"
    }
  }
}

resource "azurerm_service_plan" "service-plan-whoami-api-functions" {
  name                = "whoami-functions-service-plan"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  os_type                      = "Linux"
  sku_name                     = "FC1"
  zone_balancing_enabled       = false
  worker_count                 = 1
  maximum_elastic_worker_count = 1
}

resource "azurerm_function_app_flex_consumption" "function-app-flex-consumption-whoami-api" {
  name                = "whoami-functions-app"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  enabled                       = true
  https_only                    = true
  runtime_name                  = "python"
  runtime_version               = "3.13"
  instance_memory_in_mb         = 512
  maximum_instance_count        = 100
  public_network_access_enabled = true
  service_plan_id               = azurerm_service_plan.service-plan-whoami-api-functions.id
  storage_container_type        = "blobContainer"
  storage_authentication_type   = "StorageAccountConnectionString"
  storage_container_endpoint    = azurerm_storage_account.storage-account-whoami-api.primary_blob_endpoint
  storage_access_key            = azurerm_storage_account.storage-account-whoami-api.primary_access_key

  site_config {
    worker_count = 1
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }
}